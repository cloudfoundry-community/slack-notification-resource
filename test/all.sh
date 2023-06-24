#!/bin/bash

set -eo pipefail

on_exit() {
  exitcode=$?
  if [ $exitcode != 0 ] ; then
    echo -e '\e[41;33;1m'"Failure encountered!"'\e[0m'
  fi
}

trap on_exit EXIT

test() {
  set -e
  base_dir="$(cd "$(dirname $0)" ; pwd )"
  if [ -f "${base_dir}/../out" ] ; then
    cmd="../out"
  elif [ -f /opt/resource/out ] ; then
    cmd="/opt/resource/out"
  fi

  cat <<EOM >&2
------------------------------------------------------------------------------
TESTING: $1

Input:
$(cat "${base_dir}/${1}.out")

Output:
EOM

  result=$(cd "${base_dir}" && cat "${1}.out" | "${cmd}" . 2>&1 | tee /dev/stderr)
  echo >&2 ""
  echo >&2 "Result:"
  echo "${result}" # to be passed into jq -e
}

echo_true() {
  echo >&2 ""
  echo >&2 "Result:"
  echo "true"
}

export BUILD_PIPELINE_NAME='my-pipeline'
export BUILD_JOB_NAME='my-job'
export BUILD_NAME='my-build'
export BUILD_TEAM_NAME='main'

webhook_url='https://some.url'
base_text=":some_emoji:<https://my-ci.my-org.com/teams/main/pipelines/my-pipeline/jobs/my-job/builds/my-build|Alert!>"
sample_text="This text came from sample.txt. It could have been generated by a previous Concourse task.\n\nMultiple lines are allowed.\n"
env_vars_tail="BUILD_NAME=my-build\nVERSION=1.0.1\nQUALITY_GATE=B (ERROR)\nWITH_PIPE=<something>\nwith_GLOB=./path/to/*.jar\n"
missing_text="_(no notification provided)_"

username="concourse"
# Turn off failure on failed command return because we can't exit the script when we EXPECT a failure from a test
set +e

# Run these in a subshell so that the subshell process exits itself. If we don't run in a subshell the exit will exit THIS process
$(test curl_failure)
if [ $? -eq 0 ]; then # Since we EXPECT failure from these tests, assert that they come back with a "bad" non-zero status code.
  exit 1
else
  echo_true
fi

$(test curl_failure_with_silent)
if [ $? -eq 0 ]; then
  exit 1
else
  echo_true
fi

$(test curl_failure_without_redact_hook)
if [ $? -eq 0 ]; then
  exit 1
else
  echo_true
fi

set -e

test combined_text_template_and_file | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"${base_text}\n${sample_text}\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"

test combined_text_template_and_file_with_vars | jq -e "
  .body.text == \"${base_text}\n${sample_text}\n${env_vars_tail}\"
  "

test combined_text_template_and_file_empty | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"${base_text}\n${missing_text}\n\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"


test combined_text_template_and_file_missing | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"${base_text}\n${missing_text}\n\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"

test text | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"Inline static \`text\`\n\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"

test text_file | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"${sample_text}\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"

test text_file_with_env_vars | jq -e "
  .body.text == \"${sample_text}\n${env_vars_tail}\"
  "

test text_file_empty | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == null and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"${missing_text}\n\" and
  .body.attachments == null and
  ( .body | keys | contains([\"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\",\"attachments\"]) ) and
  ( .body | keys | length ==  7 )"

test text_file_empty_suppress | jq -e "
  ( . | keys | length == 1 ) and
  ( . | keys | contains([\"version\"]) ) and
  ( .version | keys == [\"timestamp\"] )"

test metadata | jq -e "
  ( .version | keys == [\"timestamp\"] )        and
  ( .metadata[0].name == \"url\" )              and ( .metadata[0].value == \"https://hooks.slack.com/services/TH…IS/DO…ES/WO…RK\" ) and
  ( .metadata[1].name == \"channel\" )          and ( .metadata[1].value == \"#some_channel\" ) and
  ( .metadata[2].name == \"username\" )         and ( .metadata[2].value == \"concourse\" ) and
  ( .metadata[3].name == \"text\" )             and ( .metadata[3].value == \"Inline static text\n\" ) and
  ( .metadata[4].name == \"text_file\" )        and ( .metadata[4].value == \"\" ) and
  ( .metadata[5].name == \"text_file_exists\" ) and ( .metadata[5].value == \"No\" )  and
  ( .metadata | length == 7 )"

test metadata_with_payload | jq -e "
  ( .version | keys == [\"timestamp\"] )        and
  ( .metadata[0].name == \"url\" )              and ( .metadata[0].value == \"https://hooks.slack.com/services/TH…IS/DO…ES/WO…RK\" ) and
  ( .metadata[1].name == \"channel\" )          and ( .metadata[1].value == \"#some_channel\" ) and
  ( .metadata[2].name == \"username\" )         and ( .metadata[2].value == \"concourse\" ) and
  ( .metadata[3].name == \"text\" )             and ( .metadata[3].value == \"Inline static text\n\" ) and
  ( .metadata[4].name == \"text_file\" )        and ( .metadata[4].value == \"\" ) and
  ( .metadata[5].name == \"text_file_exists\" ) and ( .metadata[5].value == \"No\" )  and
  ( .metadata[7].name == \"payload\" )          and ( .metadata[7].value | fromjson.source.url == \"***REDACTED***\" ) and
  ( .metadata | length == 8 )"

test attachments_no_text | jq -e "
  .body.text == null and
  .body.attachments[0].color == \"danger\" and
  .body.attachments[0].text == \"Build my-build failed!\" and
  ( .body.attachments | length == 1 )"

test attachments_with_text | jq -e "
  .body.text == \"Inline static text\n\" and
  .body.attachments[0].color == \"danger\" and
  .body.attachments[0].text == \"Build \`my-build\` failed!\" and
  ( .body.attachments | length == 1 )"

test attachments_no_text_and_attachments_file | jq -e "
  .body.text == null and
  .body.attachments[0].color == \"danger\" and
  .body.attachments[0].text == \"Build my-build failed!\" and
  ( .body.attachments | length == 1 )"

test attachments_with_text_and_attachments_file | jq -e "
  .body.text == \"Inline static text\n\" and
  .body.attachments[0].color == \"danger\" and
  .body.attachments[0].text == \"Build my-build failed!\" and
  ( .body.attachments | length == 1 )"

test no_attachments_no_text_and_attachments_file | jq -e "
  .body.text == null and
  .body.attachments[0].color == \"success\" and
  .body.attachments[0].text == \"Build my-build passed!\" and
  ( .body.attachments | length == 1 )"

test no_attachments_with_text_and_attachments_file | jq -e "
  .body.text == \"Inline static text\n\" and
  .body.attachments[0].color == \"success\" and
  .body.attachments[0].text == \"Build my-build passed!\" and
  ( .body.attachments | length == 1 )"

test multiple_channels | jq -e "
  .webhook_url == $(echo $webhook_url | jq -R .) and
  .body.channel == \"#another_channel\" and
  .body.icon_url == null and
  .body.icon_emoji == null and
  .body.link_names == false and
  .body.username == $(echo $username | jq -R .) and
  .body.text == \"Inline static text\n\" and
  ( .body | keys | contains([\"attachments\", \"channel\",\"icon_emoji\",\"icon_url\",\"username\",\"link_names\",\"text\"]) ) and
  ( .body | keys | length ==  7 ) and
  .body.attachments == null"

test env_file | jq -e "
  .body.text == \"Inline static text\n\" and
  .body.attachments[0].color == \"danger\" and
  .body.attachments[0].text == \"Build \`my-build\` failed! (1.0.1) - Quality Rating: B (ERROR)\" and
  .body.attachments[1].text == \"<something> - ./path/to/*.jar\" and
  ( .body.attachments | length == 2 )"

echo -e '\e[32;1m'"All tests passed!"'\e[0m'

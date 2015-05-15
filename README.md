# Slack notification sending resource 

Sends messages to [Slack](https://slack.com).

## Source Configuration

* `url`: *Required.* The webhook URL as provided by Slack. Usually in the form: `https://hooks.slack.com/services/XXXX`

## Behavior

### `out`: Sends message to Slack. 

Send message to Slack, with the configured parameters.

#### Parameters

* `text`: *Required.* Text of the message to send. Can contain links in form `<http://example.com>` or `<http://example.com|Click here!>`
* `channel`: *Optional.* Override channel to send message to. `#channel` and `#user` forms are allowed.
* `username`: *Optional.* Override name of the sender of the message.
* `icon_url`: *Optional.* Override icon by providing URL to the image.
* `icon_emoji`: *Optional.* Override icon by providing emoji code (e.g. `:ghost:`).


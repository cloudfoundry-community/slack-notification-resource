# Bug Fixes

- The `text` field of attachments now interpolates environment
  variables from the container environment (i.e. BUILD_* et al).
  Fixes #25

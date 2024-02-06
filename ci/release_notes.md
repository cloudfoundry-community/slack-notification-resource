### New feature

- Now the content of `text_file` is interpolated the same way `text` is (#99 by @bgandon).

This change in behavior may produce surprising results when the content of the file designated by `text_file` includes some environment variables that are to be printed verbatim and not expanded. We expect the impact to be very limited though.

### Improvements

- Generated new CI pipeline from [template](https://github.com/cloudfoundry-community/pipeline-templates), hosted by Gstack, that has taken over maintenance of the project.
- Updated docs
- Rebuilt resource image with latest Alpine image v3.19.1 and Bash v5.2.21

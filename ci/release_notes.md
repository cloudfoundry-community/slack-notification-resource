https://github.com/cloudfoundry-community/slack-notification-resource/pull/51

Added functionality to be able to set link_names as parameter in pipeline with it defaulting to false. Also modified the tests so they actually pass with the new added parameter. Has been tested in a pipeline with successfully notified user group by writing @ which then mentioned the group. Was tested by using

```
resource_types:
- name: slack-notification
  type: docker-image
  source:
    repository: quay.io/pontusarfwedson/slack-notification-resource
    tag: feature-link-names
```

in our pipeline (which points to a docker image build from this exact branch).



# jira-multi-repo-front

This is part of a collection of 3 repos
jira-multi-repo-back
jira-multi-repo-front
jira-multi-repo-release

The purpose is to show an example of the release of multiple services
together to production using tagged versions and Jira.

## Normal Development
This is a helper repo that shall simulate a micro-service that has its own repo.
Changes to the source code and new versions of the SW is simulated by updating
the `counter=` variable in
```shell
app/frontend/frontend-content.txt
```
The tracking of application builds when merging to main is tracked in
[jira-multi-repo-front-app](https://app.kosli.com/kosli-public/flows/jira-multi-repo-front-app/trails/)
flow with a trail naming matching git commit.

The team use Pull-requests and always have a reference to a
Jira Issue. The tracking of these attestations are done in the
[jira-multi-repo-front-source](https://app.kosli.com/kosli-public/flows/jira-multi-repo-front-source/trails/)
flow.


## Tagged version of SW ready for release
When the team is of the opinion that the SW is ready to the next release to
production they make a tagged version of the SW. This is done by pushing a tag
of the format `v.*.*.*`.

Tagged SW versions are tracked in the 
[jira-multi-repo-front-tagged](https://app.kosli.com/kosli-public/flows/jira-multi-repo-front-tagged/trails/)
flow

For each tagged version of the SW we attest a list of Jira Issues since previous tagged version.
An example for version v1.0.11 can be found [here](https://app.kosli.com/kosli-public/flows/jira-multi-repo-front-tagged/trails/v1.0.11?attestation_id=cabf6b64-45f5-4b97-a650-28811f86)

At this point the SW team has done their job and the release manager will now orchestrate
the next release and approval of SW to production.

Please see the README of `jira-multi-repo-release` for details.

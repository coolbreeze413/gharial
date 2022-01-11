# gharial
gha experiments so far...


## [1] script standalone

script generates artifact, creates PR, merges PR, creates RELEASE  

- script in the repo
- user clones repo with token, runs script: `./generate_release.sh`
- script creates artifact
- script commits artifact into new branch : `releases-no-gha/$DATE/$TIME`  
  this is so that standalone run does not also invoke the `release-on-pr.yml` workflow!
- script pushes branch to upstream
- script creates a PR from branch to master using gh-cli
- script merges PR using gh-cli
- script creates RELEASE from master, and uploads artifact into release using gh-cli


## [2] script + gh actions

script generates artifact, creates PR  
gh actions processes PR, merges PR, creates RELEASE  

[![subdmodule-updates](https://github.com/coolbreeze413/gharial/actions/workflows/release-on-pr.yml/badge.svg)](https://github.com/coolbreeze413/gharial/actions/workflows/release-on-pr.yml)

[![](https://img.shields.io/static/v1?label=actions&labelColor=444444&message=release-on-pr.yml&color=2088FF&logo=github&logoColor=2088FF)](https://github.com/coolbreeze413/gharial/blob/master/.github/workflows/release-on-pr.yml)


- script in the repo
- user clones repo with token, runs script with argument: `./generate_release.sh github-actions`
- script creates artifact
- script commits artifact into new branch : `releases/$DATE/$TIME`
- script pushes branch to upstream
- script creates a PR from branch to master using gh-cli
- gha processes PR - checks for changes in a specific directory: `release-artifacts`
- if yes, gha adds a comment, and approves review for the PR
- gha auto merges PR with squash
- gha creates a release from master and uploads artifact into release


## [3] submodule update gh action

gh actions to check if submodule is updated in a specific directory, and raise a PR 
for bumping up submodule revision in the repo.  

for straightforward use cases, use dependabot.  
for triggering PRs only when a specific file/dir of a submodule us updated, use this gha.  

[![subdmodule-updates](https://github.com/coolbreeze413/gharial/actions/workflows/submodule-updates.yml/badge.svg)](https://github.com/coolbreeze413/gharial/actions/workflows/submodule-updates.yml)

[![](https://img.shields.io/static/v1?label=actions&labelColor=444444&message=submodule-updates.yml&color=2088FF&logo=github&logoColor=2088FF)](https://github.com/coolbreeze413/gharial/blob/master/.github/workflows/submodule-updates.yml)


- check for submodule updates (revision)
  - if yes, check if change in a specific dir of interest
    - if yes, check if we already have a PR for the same specific revision (previous run of the gh action)
      - if yes, do nothing futher
      - if no, check if we already have a PR for a previous revision (unmerged, previous run of the gh action)
        - if yes, store this PR number, as we will close this PR once a new one is raised
        - if no, proceed further
      - create a new PR to bump sumbodule to latest revision
      - if previous PR for older version was raised, close it now, and add a comment pointing to
        the new PR number which supersedes the previous PR
  - done


## [4] repository-dispatch and workflow-dispatch

workflow can be triggered using a POST request to GH API.  
this can, for example be triggered from a workflow in another repo, say on a push to 'master'  

gh action to receive `repository-dispatch` and `workflow-dispatch` events is in this repo:  

[![repository-workflow-dispatch](https://github.com/coolbreeze413/gharial/actions/workflows/on-repository-workflow-dispatch.yml/badge.svg)](https://github.com/coolbreeze413/gharial/actions/workflows/on-repository-workflow-dispatch.yml)  

[![](https://img.shields.io/static/v1?label=actions&labelColor=444444&message=on-repository-workflow-dispatch.yml&color=2088FF&logo=github&logoColor=2088FF)](https://github.com/coolbreeze413/gharial/blob/master/.github/workflows/on-repository-workflow-dispatch.yml)  


examples of how a workflow from another repo can trigger this workflow through both type of events are here:  

`repository-dispatch` :  

[![trigger-repository-dispatch](https://github.com/coolbreeze413/dependabot_sub_a/actions/workflows/trigger-repository-dispatch.yml/badge.svg)](https://github.com/coolbreeze413/dependabot_sub_a/actions/workflows/trigger-repository-dispatch.yml)  

[![](https://img.shields.io/static/v1?label=actions&labelColor=444444&message=trigger-repository-dispatch.yml&color=2088FF&logo=github&logoColor=2088FF)](https://github.com/coolbreeze413/dependabot_sub_a/blob/master/.github/workflows/trigger-repository-dispatch.yml)  

`workflow-dispatch` :  

[![trigger-workflow-dispatch](https://github.com/coolbreeze413/dependabot_sub_a/actions/workflows/trigger-workflow-dispatch.yml/badge.svg)](https://github.com/coolbreeze413/dependabot_sub_a/actions/workflows/trigger-workflow-dispatch.yml)  

[![](https://img.shields.io/static/v1?label=actions&labelColor=444444&message=trigger-workflow-dispatch.yml&color=2088FF&logo=github&logoColor=2088FF)](https://github.com/coolbreeze413/dependabot_sub_a/blob/master/.github/workflows/trigger-workflow-dispatch.yml)  

NOTE: the workflows from the triggering repo (dependabot_sub_a) use the repo secret: secret.GHARIAL_PAT_SECRET  
this secret is added to the repo, with the PAT which can actually access the target repo (gharial)
default `GITHUB_TOKEN` cannot be used.  

NOTE: the same event can be sent from any REST client (cURL) using an appropriate PAT, such as from a script, instead of from the workflow of another repo.  
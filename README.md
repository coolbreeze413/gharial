# gharial
gha experiments so far...


## [1] script standalone

script generates artifact, creates PR, merges PR, creates RELEASE  

- script in the repo
- user clones repo with token, runs script: `./generate_release.sh`
- script creates artifact
- script commits artifact into new branch : `releases/$DATE/$TIME`
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
- user clones repo with token, runs script: `./generate_release.sh create-pr`
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

# gharial
gha experiments


## [1] script generate, create PR, merge PR, create RELEASE

- script in the repo
- user clones repo with token, runs script
- script creates artifact
- script commits artifact into new branch : artifact_DATE
- script pushes branch to upstream
- script creates a PR from branch to master
- script merges PR
- script creates RELEASE from master, and uploads artifact into release


## [2] script generate, create PR/gha process PR, merge PR, create RELEASE
- gha processes PR, if it is for artifact, auto-merges PR.
- gha creates release, with only artifact and no source zip/tarball

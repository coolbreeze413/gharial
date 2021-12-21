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
- gha processes PR - checks for changes in a specific directory (artifacts)
- if yes, gha adds a comment, and approves review for the PR
- gha auto merges PR with squash
- gha creates a release from master and uploads artifact into release

# gharial
gha experiments


## [1] gha PR automerge

- script in the repo
- system clones repo, runs script
- script creates artifact
- script commits artifact into new branch : artifact_DATE
- script pushes branch to upstream
- script creates a PR from branch to master
- gha processes PR, if it is for artifact, auto-merges PR.


## [2] gha CI workflow - build C file?

- c file compilation, linux?
- add CI trigger on any PR, and along with a review.

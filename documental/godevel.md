# Simple development flow in Go

## Need to keep the canonical domain & project name, so always get/install from upstream

`go get github.com/MAINTAINER/PROJECT` or similar

## Now, use git to set things up for development

1) Add the my-fork remote `git remote add my-fork git@github.com:4wrxb/PROJECT.git`
1) Fetch your fork to ensure branches are updated `git fetch my-fork`
1) Set the master branch to track my-fork's master `git branch master -u my-fork/master`
1) Add the upstream_master branch `git branch upstream_master origin/master`
1) Hard-reset to your master (you can pull if it's fast-forwardable): `git fetch my-fork master && git reset --hard FETCH_HEAD`
1) **Optional:** Rebase your master: `git rebase upstream_master`

## Things now look like this

TODO: git branch -a example

## To re-build use the go install command on the canonical name

`go install github.com/MAINTAINER/PROJECT` or similar

## To update to the latest

TODO:

## Develop on your master, cache branches to your repo as necessary (e.g. for pull requests)

TODO:

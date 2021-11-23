#!/bin/bash
REPO="$1"
if [ -z "$REPO" ]; then
  echo "Usage ./git-sync.sh repo [branch]"
  exit 1
fi

BRANCH="$2"
if [ -z "$BRANCH" ]; then
  BRANCH="master"
fi

git checkout $BRANCH
git pull origin $BRANCH

REMOTE="$(git remote | grep eea)"
if [ -z "$REMOTE" ]; then
    git remote add eea $1
fi

git fetch eea
git merge --no-edit eea/$BRANCH
git push origin $BRANCH

GIT_TAG=`git tag`
for i in $GIT_TAG; do
  if [[ $i == "jenkins"* ]]; then
    git tag -d $i
    git push origin :refs/tags/$i
  fi
done

git push --tags

#!/bin/bash
if [ -z "$(git status --porcelain)" ]; then
  # Working directory is clean

  # save hash of the current commit that will be deployed
  COMMIT_HASH=$(git rev-parse --short HEAD)
  SITEGEN_TMP_OUPUT=/tmp/sitegen-tmp-build

  # build site and move it to temporary folder
  sitegen build
  mkdir -p ${SITEGEN_TMP_OUPUT}
  rm -rf ${SITEGEN_TMP_OUPUT}/*
  cp src/CNAME ./output/
  mv ./output/* ${SITEGEN_TMP_OUPUT}
  
  # deploy site to the static pages branch
  git checkout gh-pages
  git status
  rm -r ./* &&  mv ${SITEGEN_TMP_OUPUT}/* .
  git add .
  git status
  git commit -m "Deploy commit: $COMMIT_HASH"
#  git push
else
  # Working directory has uncommitted changes
  echo "Please make all changes are committed before running this script."
fi

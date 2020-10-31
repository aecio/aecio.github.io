#!/bin/bash
if [ -z "$(git status --porcelain)" ]; then
  # Working directory is clean
  sitegen build
  SITEGEN_TMP_OUPUT=/tmp/sitegen-tmp-build
  mkdir -p ${SITEGEN_TMP_OUPUT}
  rm -rf ${SITEGEN_TMP_OUPUT}/*
  cp src/CNAME ./output/
  mv ./output/* ${SITEGEN_TMP_OUPUT}
  git checkout master
  git status
  rm -r ./* &&  mv /tmp/sitegen-tmp-build/* .
  git add .
  git status
else
  # Working directory has uncommitted changes
  echo "Please make all changes are committed before running this script."
fi

#! /bin/bash

release=$1

if [[ -z "${release}" ]]
then
  echo "you must provide a release name (i.e. "v0.1.6")"
  exit 1
fi

git checkout main && \
git pull --rebase origin main && \
git tag -a -m "${release}" "${release}" && \
git push --follow-tags origin main


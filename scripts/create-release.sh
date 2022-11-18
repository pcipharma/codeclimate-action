#! /bin/bash

release=$1

if [[ -z "${release}" ]]
then
  echo "you must provide a release name (i.e. "v0.1.6")"
  exit 1
fi

# delete tags first
git tag -d "${release}" && \
git push origin --delete "${release}"

# create tag
git checkout main && \
git pull --rebase origin main && \
git push origin main && \
git tag -a -m "${release}" "${release}" && \
git push --follow-tags origin main

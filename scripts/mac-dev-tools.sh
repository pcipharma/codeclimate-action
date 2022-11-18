#!/bin/bash
set -e

pwd=$(pwd)
path=$(dirname "$0")
cd "${path}"

if [[ -e ../requirements.txt ]]
then
    echo "Installing mkdocs (python) modules"
    python3 -m pip install -r ../requirements.txt
fi

if ! command -v brew &> /dev/null
then
    echo "Installing homebrew"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/main/install.sh
fi

echo "Homebrew installed. Running brew bundle"
brew bundle -v

echo "Installing pre-commit modules"
pre-commit install --hook-type pre-push
pre-commit install --hook-type commit-msg
pre-commit install --hook-type pre-commit

echo "Installing node packages"
npm install

cd "${pwd}"
echo "All done!"

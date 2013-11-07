#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

git config --global alias.bump "!$DIR/version-bump.sh"

cat << __EOF
Git aliases successfully installed.

__EOF

curl https://raw.github.com/InnovaCo/git-flow/master/README.md


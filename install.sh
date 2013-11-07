#!/bin/bash

git config --global alias.bump "!$PWD/version-bump.sh"

cat << __EOF
Git aliases successfully installed.

__EOF

curl https://raw.github.com/InnovaCo/git-flow/master/README.md


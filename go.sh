#!/bin/bash
set -e

branch=`git branch | grep -e '^*' | sed -e 's/* //g'`
sha=$(git rev-list HEAD -1)

source .go # import $pipeline, $host variables

[ -z "$pipeline" -o -z "$host" -o -z "$branch" -o -z "$sha" ] && echo "Insufficient variables for call" && exit 1

username=$GO_USER

[ -z "$username" ] && read -p "Go username:" username

curl -u $username -d "variables%5BBRANCH%5D=$branch&variables%5BSHA%5D=$sha&" "http://$host/go/api/pipelines/$pipeline/schedule"

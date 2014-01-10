#!/bin/bash
set -e

function print_help {
	echo ""
	echo "Usage: bump-version.sh [-m %message%] [%path_to_dependant%]"
	echo ""
	echo "Example: ~/dev/awesome-library\$ bump-version.sh -m \"Version bump.\" ../awesome-product/"
}

case $1 in
	"-m" )
		commit="$2"
		path_to_dep="$3"
		;;
	"--help" | "--?" )
		print_help
		exit 0
		;;
	* )
		path_to_dep="$1"
		;;
esac

function check_dependency {
	cwd=$(pwd)
	component_name=$1
	dep=$2

	if [ -z $dep ]; then
		return
	fi

	cd $dep

	if [ ! -f "bower.json" ]; then
		echo -e "\033[0;31mbower.json for dependency $dep can not be found.\033[0m"
		print_help
		exit 2
	fi

	dependency_name=$(cat "bower.json" | grep -E -e '"name": "[^"]+"' | sed -E 's/[^:]+: "([^"]+)".+/\1/g')

	if [[ -z "$dependency_name" || "$dependency_name" = "$component_name" ]]; then
		echo -e "\033[0;31mWrong dependency name '$dependency_name'\033[0m"
		print_help
		exit 2
	fi

	git_status=$(git status | grep -E -e "nothing to commit\W+working directory clean")

	if [ -z "$git_status" ]; then
		echo -e "\033[0;31mDependency working directory '$dep' is not clean. Clean it up and try again.\033[0m"
		print_help
		exit 2
	fi

	cd $cwd
}

branch_name=`git branch | grep -e '^*' | sed -e 's/* //g'`

if [ "$branch_name" != "master" ]; then
	echo -e "\033[0;33mPlease, checkout to master branch.\033[0m"
	exit 0
fi

branch_status=$(git remote show origin | grep -E -e "master\s+pushes\sto\smaster\s+\([^\)]+\)" | sed -E "s/.+\((.+)\)/\1/g")

case $branch_status in
	'fast-forwardable' | 'up to date' )
		;;
	* )
		echo -e "\033[0;33mYour branch is not up to date.\033[0m"
		exit 1
		;;
esac

git push origin master --dry-run 2>/dev/null

if [ $? -ne 0 ]; then
	echo -e "\033[0;33mCan't push your 'master' changes to the remote.\033[0m"
	exit 1;
fi

component_version=$(cat bower.json | grep -E -e '"version": "[^"]+"' | sed -E 's/[^:]+: "([^"]+)".+/\1/g')
component_name=$(cat bower.json | grep -E -e '"name": "[^"]+"' | sed -E 's/[^:]+: "([^"]+)".+/\1/g')

check_dependency $component_name $path_to_dep

last_version=$(git describe --tags --abbrev=0)

major_pattern="s/^v([^.]+)\..+/\1/g"
minor_pattern="s/^v[^.]+\.([^.]+).*/\1/g"
patch_pattern="s/^v[^.]+\.[^.]+\.([^.-]+).*/\1/g"

major_version=$(echo $last_version | sed -E $major_pattern)
minor_version=$(echo $last_version | sed -E $minor_pattern)
patch_version=$(echo $last_version | sed -E $patch_pattern)

tag_sha=$(git rev-list $last_version -1)
head_sha=$(git rev-list HEAD -1)

if [[ "$component_version" < "$last_version" ]]; then
	if [[ $tag_sha != $head_sha ]]; then
		patch_version=$(($patch_version + 1))
	fi

	component_version="$major_version.$minor_version.$patch_version"
fi

component_version="v$component_version"

if [ -z "$commit" ]; then
	commit=$(git log -1 | grep -v -E "^(commit |Author:|Date:|\s*$)" | sed -E "s/^[ ]+//g")
fi

if [[ $tag_sha != $head_sha ]]; then
	git tag -a $component_version -m "Version bump $component_version" HEAD

	git push origin master
	git push origin --tags

	echo -e "\033[0;32mDone.\033[0m New version: \033[0;33m$component_version\033[0m"
fi

echo -e "\033[0;34mLinking $component_name $component_version to $path_to_dep\033[0m"

if [ -z $path_to_dep ]; then
	exit 0
fi

check_dependency $component_name $path_to_dep

cd $path_to_dep

cat "bower.json" | sed -E "s/(\"$component_name\"\s*:.+#).+\"/\1$component_version\"/g" > bower.json.tmp
rm bower.json
mv bower.json.tmp bower.json

git add "bower.json"
git commit -m "$commit"

if [ $? -ne 0 ]; then
	echo -e "\033[0;31mCommit unsuccessful.\033[0m"
	exit 3
fi

branch_name=`git branch | grep -e '^*' | sed -e 's/* //g'`

git push origin $branch_name

echo -e "\033[0;32mDone!\033[0m — we have a script for that."




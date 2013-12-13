git-flow
========

Some automated tools for use in order to achieve company's git-flow

## Installation

1. Make sure that Git is installed.
2. Clone the repository into custom folder.
3. Run `./install.sh` inside the cloned repo.

>  Profit!


## Version bump

"Version-bump" is automated version bumping tool for libraries and optional linking this new version to product that using it.

Usage: `git bump [-m %message%] [%path_to_dep%]`

 `git bump` ensures that you are running it inside "master" branch of your library and makes sure that it's up to date. After that it makes a dry-run push and notifies you about troubles if any.

If %path_to_dep% is specified then tool assumes that this is a path to repo for a product that depends on your library. It tries to find "bower.json" and write down new version of the library into it.

If everything is okay the tool changes dependency version to the new one and commit changes with message provided with "-m" key of the command or last message used to commit changes for the library and pushes this changes to the origin.

### Version determination algorithm

The tool checks `bower.json` file in order to find out version of the library you are about to bump. Also it checks last tagged version of the library at the origin.

Using the highest version from two above described the tool pushes local changes to the origin, creates tag with new version and pushes all local tags to the origin.



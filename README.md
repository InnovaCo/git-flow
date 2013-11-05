git-flow
========

Some automated tools for use in order to achieve company's git-flow

## Version bump

Version bump is automated version bumping tool for dependency and optional linking new version to product that using it.

Usage: `git bump [-m %message%] [%path_to_dep%]`

Try `git bump --?` to get th hint above.

When you run `git bump` the tool ensures that you are running it inside "master" branch and makes sure that it is up to date. After that it make a dry-run  push and notifies you about troubles if any.

It checks the "bower.json" file to find out version of the library you are about to bump.

It checks last tagged version of the library at the origin.

Using the highest version the tool push local changes to the origin, create tag with new version and push all local tags to the origin.

If %path_to_dep% is specified then tool assumes that this is a path to repo for a product that depends on current repo library. It tries to find "bower.json" and record for the library.

If everything is okay the tool change dependency version to the new one and commit changes with message provided with "-m" key of the command or last message used to commit changes for the library.

Push the changes to the origin.

#!/bin/sh

# I use this shell script to automatically build
# .love-files for games, that I've changed
# from the last version of the repository.

is_version_tag() {
    case "$1" in
        v*) echo "true";;
        *) echo "false";;
    esac
}

usage(){
 echo "Usage: sh make-love.sh [version]"
 echo "If no version is given, the version of the"
 echo "current git HEAD is used."
}

if [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# check if HEAD is pointed to by a version tag
# or use the
if [ "$1" ]; then
    current_tag="$1"
else
    current_tag="$(git tag --points-at HEAD)"
fi

if [ "$(is_version_tag $current_tag)" = "true" ]; then
    echo "Processing new releases for version $current_tag..."
else
    echo "Version '$current_tag' is not a version tag - exiting."
    exit 1
fi

IFS="
"
for game in $(find . -maxdepth 1 -type d -printf "%P\n"); do
    if [ -f "$game/main.lua" ]; then
        echo "Checking for new version of '$game':"

        # check for each existing version tag, if it
        # has any changes to the current code of the game.
        # if not, set the tag to *same_version*
        same_version=""
        for tag in $(git tag); do
            # skip the current tag
            if [ "$tag" = "$current_tag" ]; then
                break
            fi

            if [ "$(is_version_tag "$tag")" = "true" ]; then
                changes="$(git diff $tag $game)"
                if [ ! "$changes" ]; then
                    same_version="$tag"
                    break
                fi
            fi
        done

        # if a same version exists, simply print this information
        # additionally check, if the associated love file also exists.
        if [ "$same_version" ]; then
            echo " * Found same version: $same_version."
            lovefile="releases/tag/$same_version/$game-$same_version.love"
            if [ ! -f "$lovefile" ]; then
                echo " * WARNING: '$lovefile' does not exist!"
            fi
        else
            lovedir="releases/tag/$current_tag"
            lovefile="$lovedir/$game-$current_tag.love"
            echo " * Creating $lovefile"
            mkdir -p "$lovedir" || exit 2
	        7z a -tzip "$lovefile" -w "$game"/. >> /dev/null || exit 2
        fi
    fi
done

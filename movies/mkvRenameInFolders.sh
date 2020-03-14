#!/bin/sh

# This script takes all mkv files in the (sub)directory and sets it's Movie name/Title
# Requires mkvtools (mkvpropedit) and mediainfo installed
#
# param1 Starting directory (defaults to current)
# param2 Default action to do with files
# (Keep the name?[1] / Type a new name?[2] / Use the filename as a movie name?[3])
# Be carefaul with param2 since this script doesn't (atm) back up the existing movie names.
#
# TODO Keep track of changed files 0 - to make reruns without asking about fixed files
# TODO Color things up
# TODO Look into titles for files besides .mkv
# TODO Backup old titles in case of doing smth wrong
# TODO Do smth in case mkvpropedit failing

IFS=$'\n'; set -f

updateTitle() {
    mkvpropedit "${1}" -e info -s title="${2}"
    echo "✅ Updated to \"${2}\"";
}

getMovieTitle() {
    echo "$(mediainfo ${1} | grep "Movie name" | sed 's/^.*: //')";
}

parseFilename() {
    filename=${1##*/}
    filename=${filename%.*}
    echo ${filename}
}

chooseAction() {
    f="${1}"
    curFilename="${2}"
    defaultAction="${3}"

    if [[ -n "${defaultAction}" ]]; then
        ans="${defaultAction}"
    else
        read -p "Keep the name?[1] / Type a new name?[2] / Use the filename as a movie name?[3] : " -n 1 ans
        echo
    fi

    case "${ans}" in

    1)
        echo "Keeping the old name"
        ;;
    2)
        read -p "New movie name: " newName
        updateTitle ${f} ${newName}
        ;;
    3)
        updateTitle ${f} ${curFilename}
        ;;
    *)
        echo "Invalid char \"${ans}\""
        chooseAction $@
        ;;
    esac
    echo
}

renameMovies() {
    for f in $(find ${1} -name '*.mkv'); do
        curTitle="$(getMovieTitle ${f})"
        curFilename="$(parseFilename ${f})"
        
        echo "File location - ${f}"
        echo "File name     - ${curFilename}"
        echo "Movie name    - ${curTitle}"

        chooseAction ${f} ${curFilename} ${2}
    done
    echo "Done"

}

renameMovies ${1:-$(pwd)} ${2}

unset IFS; set +f

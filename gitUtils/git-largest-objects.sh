#!/bin/bash
#set -x 
 
# Shows you the largest objects in your repo's pack file.
# Written for osx.
#
# @see https://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
# @author Antony Stubbs

## see also : http://naleid.com/blog/2012/01/17/finding-and-purging-big-files-from-git-history

GIT_DIR=`git rev-parse --show-toplevel` || exit $?
 
# set the internal field spereator to line break, so that we can iterate easily over the verify-pack output
IFS=$'\n';
 
# list all objects including their size, sort by size, take top 10
objects=`git verify-pack -v $GIT_DIR/.git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head`
 
echo "All sizes are in kB's. The pack column is the size of the object, compressed, inside the pack file."
 
output="size,pack,SHA,location"
for y in $objects
do
    # extract the size in bytes
    size=$((`echo $y | cut -f 5 -d ' '`/1024))
    # extract the compressed size in bytes
    compressedSize=$((`echo $y | cut -f 6 -d ' '`/1024))
    # extract the SHA
    sha=`echo $y | cut -f 1 -d ' '`
    # find the objects location in the repository tree
    other=`git rev-list --all --objects | grep $sha`
    #lineBreak=`echo -e "\n"`
    output="${output}\n${size}\t,${compressedSize}\t,${other}"
done
 
echo -e $output
#!/bin/bash

function usage()
{
  echo "Usage:"
  echo "./run_transform_comments.sh -i <input file>"
}

# parse arguments
while [[ "$#" > 0 ]]; do case $1 in
  -i|--input) INPUT="$2"; shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z $INPUT ]; then 
  usage
  exit -1
fi;

# set file to full path
INPUT=$(pwd)/$INPUT

set -eu

# set working directory to directory of the script
cd $(dirname $0)
Rscript run_transform_comments.r $INPUT


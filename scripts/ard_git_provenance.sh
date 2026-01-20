#!/bin/bash

# ARD Pipeline git version provenance tracking
#
# This script attempts to capture git metadata to help track
# software development versions used for ARD Pipeline jobs.
# A minimal set of git data is included to identify which repo
# and commit version was used to produce ARD data.
#
# The git status is included to indicate if the repo is dirty,
# thus potentially introducing different behaviour.

# Usage: ard_git_provenance.sh <dest-dir> <timestamp-string>


# parse args
DEST=$1
TIMESTAMP=$2

if [ -z $DEST ]; then
  echo "ERROR: missing DEST argument" >&2
  exit 1
fi

if [ -z $TIMESTAMP ]; then
  echo "ERROR: missing TIMESTAMP argument" >&2
  exit 1
fi


# ensure conda env is active
if [ -z $(which pip 2>/dev/null) ]; then
  echo "No pip. Is conda env activated?" >&2
  exit 1
fi

repo_path=$(pip show ard-pipeline | egrep 'Editable project' | egrep -o "\/g\/data[/a-zA-Z0-9_-]+")

if [ -z '$repo_path' ]; then
  echo 'Cannot find editable ARD pipeline repo via pip' >&2
  exit 1
fi

# collect data for provenance file output
git_st=$(git -C $repo_path status -s)
git_head=$(git -C $repo_path rev-parse HEAD)
git_br=$(git -C $repo_path branch --show-current)

# write as JSON, following rest of ARD Pipeline
provenance_path="$DEST/$TIMESTAMP-provenance.json"

echo "{" > $provenance_path
echo "  \"job_date\": \"$TIMESTAMP\"," >> $provenance_path
echo "  \"repo_path\": \"$repo_path\"," >> $provenance_path
echo "  \"git_head\": \"$git_head\"," >> $provenance_path
echo "  \"git_branch\": \"$git_br\"," >> $provenance_path
echo "  \"git_status\": \"$git_st\"" >> $provenance_path
echo "}" >> $provenance_path

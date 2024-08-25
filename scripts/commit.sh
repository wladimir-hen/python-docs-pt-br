#!/bin/sh
# Commit changed files filtering to the git repository
#
# SPDX-License-Identifier: CC0-1.0

set -eu

cd $(dirname $0)/../cpython/Doc/locale/${PYDOC_LANGUAGE}/LC_MESSAGES

set +u
if [ -n "${CI+x}" ]; then
  git config user.email "github-actions[bot]@users.noreply.github.com"
  git config user.name "github-actions[bot]"
fi
set -u

# Set for removal the deleted obsolete PO files
git status -s | grep '^ D ' | cut -d' ' -f3 | xargs -r git rm -v

# Add only updates that do not consist only of 'POT-Creation-Date' header change
git diff -I'^"POT-Creation-Date: ' --numstat *.po **/*.po | cut -f3 | xargs -r git add -v

# Add currently untracked PO files, and update other helper files
git add -v $(git ls-files -o --exclude-standard *.po **/*.po) .tx/config stats.json potodo.md

# Commit only if there is any cached file
git diff-index --cached --quiet HEAD || git commit -vm "Update translations"

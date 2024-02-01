#!/bin/bash

# Default branch name
default_branch="main"

# List branches that are merged into the default branch
echo "List of branches merged into '$default_branch':"
git branch -r --merged "$default_branch" | grep -vE "HEAD|$default_branch" | sed 's/origin\///'

# Prompt user before proceeding
read -p "Do you want to proceed with deleting merged branches (not including $default_branch)? (y/n): " answer
if [ "$answer" != "y" ]; then
    echo "Aborted branch deletion."
    exit 0
fi

# Iterate over merged branches
for branch in $(git branch -r --merged "$default_branch" | grep -vE "HEAD|$default_branch" | sed 's/origin\///'); do
    # Delete the remote branch
    git push origin --delete "$branch"
    echo "Deleted remote branch: $branch"
done

# Optionally, delete local branches that have a corresponding deleted remote branch
git remote prune origin

echo "Merged branch cleanup completed."

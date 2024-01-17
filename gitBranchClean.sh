#!/bin/bash

# Define the threshold in seconds (30 days)
threshold=$((30 * 24 * 60 * 60))

# Get the current timestamp
current_time=$(date +%s)

# Pattern for branch names
branch_pattern="rc/*"

# List branches matching the pattern "rc/*" and indicate if merged or unmerged
echo "List of branches matching pattern '$branch_pattern':"
git fetch --prune
for branch in $(git branch -r | grep -E "origin/$branch_pattern" | sed 's/origin\///'); do
    # Check if the branch is merged or unmerged
    merged_status=$(git branch -r --merged "$branch" | grep "$branch" | wc -l)

    if [ $merged_status -gt 0 ]; then
        echo "Merged: $branch"
    else
        echo "Unmerged: $branch"
    fi
done

# Prompt user before proceeding
read -p "Do you want to proceed with deleting branches matching '$branch_pattern' older than 30 days? (y/n): " answer
if [ "$answer" != "y" ]; then
    echo "Aborted branch deletion."
    exit 0
fi

# Iterate over branches matching the pattern
for branch in $(git branch -r | grep -E "origin/$branch_pattern" | sed 's/origin\///'); do
    # Get the last commit date of the branch in ISO format
    last_commit_date=$(git log -1 --format="%cd" --date=iso "origin/$branch")

    # Convert the ISO date to seconds since the epoch
    last_commit_time=$(date -d "$last_commit_date" +%s)

    # Calculate the age of the branch
    age=$((current_time - last_commit_time))

    # Check if the branch is older than the threshold
    if [ $age -gt $threshold ]; then
        # Delete the remote branch
        git push origin --delete "$branch"
        echo "Deleted remote branch: $branch"
    fi
done

# Optionally, delete local branches that have a corresponding deleted remote branch
git remote prune origin

echo "Branch cleanup completed."

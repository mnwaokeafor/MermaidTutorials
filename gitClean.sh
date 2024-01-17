]#!/bin/bash

# Define the threshold in seconds (30 days)
threshold=$((30 * 24 * 60 * 60))

# Get the current timestamp
current_time=$(date +%s)

# Iterate over all remote branches
git fetch --prune
for branch in $(git branch -r | grep -vE "HEAD|main" | sed 's/origin\///'); do
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



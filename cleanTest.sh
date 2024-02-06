#!/bin/bash

# Define the threshold in seconds (30 days)
threshold=$((30 * 24 * 60 * 60))

# Get the current timestamp
current_time=$(date +%s)

# Display header
echo "Branches older than 30 days:"

# List all remote branches and check if they are merged or unmerged
git fetch --prune
for branch in $(git branch -r | grep -vE "HEAD|main|master|development" | sed 's/origin\///'); do
    # Check if the branch is merged or unmerged
    merged_status=$(git branch -r --merged "$branch" | grep "$branch" | wc -l)

    # Get the last commit date of the branch
    last_commit_date=$(git log -1 --format="%ci" --grep="^commit" --date=iso "origin/$branch" | awk '{print $1}')

    # Convert the last commit date to seconds since the epoch using awk
    last_commit_time=$(date -d "$last_commit_date" +%s 2>/dev/null || date -jf "%Y-%m-%d" "$last_commit_date" +%s 2>/dev/null)

    # Calculate the age of the branch
    age=$((current_time - last_commit_time))

    # Check if the branch is older than the threshold
    if [ $age -gt $threshold ]; then
        # Display branch information
        echo "$branch (Last commit: $last_commit_date, Status: $(if [ $merged_status -gt 0 ]; then echo "Merged"; else echo "Unmerged"; fi))"

        # Prompt to delete merged branches
        if [ $merged_status -gt 0 ]; then
            read -p "Do you want to delete the merged branch '$branch'? (y/n): " answer
            if [ "$answer" == "y" ]; then
                # Delete the remote branch
                git push origin --delete "$branch"
                echo "Deleted remote branch: $branch"
            fi
        else
            # Prompt to delete unmerged branches
            read -p "Do you want to delete the unmerged branch '$branch'? (y/n): " answer
            if [ "$answer" == "y" ]; then
                # Delete the remote branch
                git push origin --delete "$branch"
                echo "Deleted remote branch: $branch"
            fi
        fi
    fi
done

# Optionally, delete local branches that have a corresponding deleted remote branch
git remote prune origin

echo "Branch cleanup completed."

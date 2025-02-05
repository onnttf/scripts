#!/bin/bash

# Check if folder is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

folder="$1"

# Remove trailing slash from folder path, if any
folder=$(echo "$folder" | sed 's:/*$::')

# Check if the provided folder exists
if [ ! -d "$folder" ]; then
    echo "Error: '$folder' is not a valid directory."
    exit 1
fi

# Step 1: Find and output .DS_Store files (limit to files only)
ds_store_files=$(find "$folder" -type f -name '.DS_Store')

# If no .DS_Store files are found
if [ -z "$ds_store_files" ]; then
    echo "No .DS_Store files found in '$folder'. Nothing to delete."
    exit 0
fi

# If .DS_Store files are found, print them
echo "The following .DS_Store files will be deleted:"
echo "$ds_store_files"

# Step 2: Ask for confirmation before backup and deletion
read -p "Do you want to delete these files by backing them up? (y/n): " confirm
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]') # Convert to lowercase

# If the user confirms with 'y', proceed with backup (deletion process)
if [[ "$confirm" =~ ^(y|yes)$ ]]; then
    # Backup .DS_Store files and record their relationship
    backup_folder="$folder/DS_Store_Backups"
    mkdir -p "$backup_folder" # Ensure the backup folder exists
    backup_file="$backup_folder/backup_relationship.txt"

    # Clear backup relationship file if it already exists
    >"$backup_file"

    echo "Backing up and deleting .DS_Store files..."

    # Backup files and record the relationships (move operation)
    success_count=0
    fail_count=0
    while IFS= read -r file; do
        backup_path="$backup_folder/$(basename "$file")"
        if mv "$file" "$backup_path"; then
            echo "$file -> $backup_path" >>"$backup_file" # Write to the backup relationship file
            ((success_count++))
        else
            ((fail_count++))
        fi
    done <<<"$ds_store_files"

    # Optimized summary of results related to "deletion"
    echo "$success_count .DS_Store file(s) successfully backed up (moved) and deleted."
    if [ "$fail_count" -gt 0 ]; then
        echo "$fail_count .DS_Store file(s) failed to back up (move)."
    fi

    echo "Deletion completed. The .DS_Store files have been moved to '$backup_folder'."
else
    echo "Operation canceled. No files were backed up or deleted."
fi

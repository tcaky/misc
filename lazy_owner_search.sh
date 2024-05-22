#!/bin/bash

TOP_FOLDER_ID="$1"
USER_ACCOUNT="$2"
ACCESS_TOKEN="$(gcloud auth print-access-token)"

# Function to create a batch request for project IAM policies
get_iam_policies() {
    local projects=("$@")
    echo "--batch_boundary"
    for project_id in "${projects[@]}"; do
        echo "Content-Type: application/http"
        echo "Content-ID: $project_id"
        echo ""
        echo "GET /v1/projects/$project_id:getIamPolicy HTTP/1.1"
        echo "Authorization: Bearer $ACCESS_TOKEN"
        echo ""
    done
}

# Recursive function to process folders and projects
process_folder() {
    local folder_id="$1"
    local projects=($(gcloud projects list --filter="parent.id=$folder_id" --format="value(projectId)"))
    local subfolders=($(gcloud resource-manager folders list --folder="$folder_id" --format="value(name)"))

    # If there are projects, process them in batches
    if [ ${#projects[@]} -gt 0 ]; then
        get_iam_policies "${projects[@]}" | curl -s -X POST "https://cloudresourcemanager.googleapis.com/batch" \
            -H "Content-Type: multipart/mixed; boundary=batch_boundary" \
            --data-binary @- \
            | jq -c '.responses[] | select(.body.bindings[] as $b | $b.role == "roles/owner" and ($b.members[] | contains("user:'"$USER_ACCOUNT"'"))).id' | xargs -I{} echo "User '$USER_ACCOUNT' is an owner in project: {}"
    fi

    # Process subfolders recursively
    for subfolder_id in "${subfolders[@]}"; do
        process_folder "${subfolder_id##folders/}"
    done
}

# Start processing from the top folder
process_folder "$TOP_FOLDER_ID"

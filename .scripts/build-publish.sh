#!/bin/bash

# Include functions
source ./.scripts/testfunctions.sh

# Parameters
REPO=${$1//"docker-"/""}
GITHUB_REF="refs/heads/main"

# Get all the releases
releases=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/saltstack/salt/releases | jq '.[].tag_name')

# Remove all the 2016 releases
releases="$(echo "$releases" | grep -v 2016)"

# Remove all the 2017 releases
releases="$(echo "$releases" | grep -v 2017)"

# Remove all the 2018 releases
releases="$(echo "$releases" | grep -v 2018)"

# Remove all the 2019 releases
releases="$(echo "$releases" | grep -v 2019)"

releases_array=""

# Blacklist releases
## 3000.1 = Saltstack script does not parse this release -> repo does not have GPG key for it.
for release in $releases 
do
    release_name=$(echo "$release" | tr -d '"')
    release_name_without_v=$(echo "$release_name" | tr -d 'v')
    if [ "$release_name_without_v" == "3000.1" ]; then
        continue
    else
        releases_array="$releases_array $release_name_without_v"
    fi
done

for release in $(echo "$releases_array" | sort -r)
do
    release_name=$(echo "$release" | tr -d '"')
    release_name_without_v=$(echo "$release_name" | tr -d 'v')
    
    echo_info "Build $REPO:$release_name_without_v is started"
    if ! docker build -t "$REPO":"$release_name_without_v" --build-arg DOCKER_TAG="${release_name_without_v}" .; then
        echo_failed "Build $REPO:$release_name_without_v had an error"
        exit 1
    else
        echo_ok "Build $REPO:$release_name_without_v succesful"
    fi

    echo_info "Push $REPO:$release_name_without_v is started"
    if ! docker push "$REPO":"$release_name_without_v"; then
        echo_failed "push $REPO:$release_name_without_v had an error"
        exit 1
    else
        echo_ok "push $REPO:$release_name_without_v succesful"
    fi
done

branch=$(echo "$GITHUB_REF" | tr "/" " ")

if [[ "$branch" =~ "main" ]]; then
    echo_info "Build stable release"
    if ! docker build -t "$REPO":stable .; then
        echo_failed "Build $REPO:stable had an error"
        exit 1
    else
        echo_ok "Build $REPO:stable succesful"
    fi
    if ! docker push "$REPO":stable; then
        echo_failed "push $REPO:stable had an error"
        exit 1
    else
        echo_ok "push $REPO:stable succesful"
    fi
fi
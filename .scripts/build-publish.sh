#!/bin/bash

# Include functions
source ./.scripts/testfunctions.sh

# Parameters
REPO="$1"

# Get all the releases
releases=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/saltstack/salt/releases | jq '.[].tag_name')

# Remove all the 2016 releases
releases=$(echo "$releases" | grep -v 2016)

# Remove all the 2017 releases
releases=$(echo "$releases" | grep -v 2017)

# Remove all the 2018 releases
releases=$(echo "$releases" | grep -v 2018)

for release in $(echo "$releases" | sort)
do
    release_name=$(echo "$release" | tr -d '"')
    release_name_without_v=$(echo "$release_name" | tr -d 'v')
    echo_info "Build $REPO:$release_name_without_v is started"
    if docker build -t "$REPO":"$release_name_without_v" --build-arg DOCKER_TAG="${release_name_without_v}" .; then
        echo_failed "Build $REPO:$release_name_without_v had an error"
    else
        echo_ok "Build $REPO:$release_name_without_v succesful"
    fi

    echo_info "Push $REPO:$release_name_without_v is started"
    if docker push "$REPO":"$release_name_without_v"; then
        echo_failed "push $REPO:$release_name_without_v had an error"
    else
        echo_ok "push $REPO:$release_name_without_v succesful"
    fi
done
#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=demo-jira-tagged-version.sh
ROOT_DIR=$(dirname $(readlink -f $0))/..
JIRA_KEYS=""

function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME <options> [JIRA-KEY] [JIRA-KEY] ...

Script that will demonstrate update of frontend SW with Jira issues and
making a tagged version.

This script should be used together with the demo-jira-release.sh in the jira-multi-repo-release repo.

It will loop over each JIRA-KEY and create a branch and do an update of the SW for each of them

Options are:
  -h          Print this help menu
EOF
}

function check_arguments
{
    while getopts "h" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    # Remove options from command line
    shift $((OPTIND-1))

    if [ $# -eq 0 ]; then
        echo "Missing JIRA-KEYs"
    fi
    JIRA_KEYS=("$@")
}

function wait_for_github_actions
{
    sleep 10
    echo -n "Waiting for GitHub Actions to complete "

    while true; do
        result=$(gh run list --json status)
        # Check if there are any workflows that are not completed
        if echo "$result" | jq -e '.[] | select(.status != "completed")' > /dev/null; then
            echo -n "."
            sleep 2
        else
            break
        fi
    done
    echo
}


function update_content_file
{
    local file=$1; shift
    # Increment the value after counter= in the file
    sed -i -E 's/(counter=)([0-9]+)/echo "\1$((\2+1))"/e' ${file}
    grep "counter=" ${file} | sed "s/counter=//"
}

function get_current_version_tag
{
    git fetch --tags
    git tag -l "v*.*.*" --sort=-version:refname | head -n1
}

function update_version_tag
{
    local currentTag;
    git fetch --tags
    currentTag=$(get_current_version_tag)
    newTag=$(echo $currentTag | awk -F. '{$NF = $NF + 1; print}' OFS=.)
    git tag -a ${newTag} -m "Version ${newTag}"
    git push origin ${newTag}
}

main()
{
    check_arguments "$@"

    for JIRA_KEY in "${JIRA_KEYS[@]}"; do
        echo; echo "*** Create a branch for issue '${JIRA_KEY}', update app and make a pull-request"
        git checkout -b ${JIRA_KEY}-demo
        VER=$(update_content_file app/frontend/frontend-content.txt)
        git add app/
        git commit -m "${JIRA_KEY} Updated SW version=${VER}"
        git push; wait_for_github_actions
        gh pr create --fill
        echo; echo "*** Waiting for pull request to do required checks before merge"; wait_for_github_actions
        gh pr merge --auto --squash --delete-branch; wait_for_github_actions
        echo; echo "*** Wait for build on main to finish"; wait_for_github_actions
    done

    echo; echo "*** Create and push next version tag"
    update_version_tag; wait_for_github_actions

    echo; echo "*** New tagged version $(get_current_version_tag) created"
}

main "$@"

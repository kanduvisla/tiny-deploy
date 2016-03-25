#!/usr/bin/env bash

while getopts ":u:h:s:d:" opt; do
    case $opt in
        # Get username:
        u)
            SSH_USER=$OPTARG;
            ;;
        h)
            SSH_HOST=$OPTARG;
            ;;
        s)
            SSH_SOURCE=$OPTARG;
            ;;
        d)
            SSH_DESTINATION=$OPTARG;
            ;;
    esac
done

# Check if all required parameters are set:
if [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ] || [ -z "$SSH_SOURCE" ] || [ -z "$SSH_DESTINATION" ]; then
    printf '\033[1;37mTiny Deploy\033[0m
---
A small deployment script that deploys a source directory to a target
directory using SSH. The only requirement is that the remote server
accepts the user by authenticating with a public key.

\033[1;37mUsage:\033[0m
    ./td.sh -husd

\033[1;37mParameters:\033[0m
    -h      The SSH Host to deploy to
    -u      The username to use
    -s      The source directory to deploy from
    -d      The target directory to deploy to

\033[1;37mExample:\033[0m
    ./td.sh -h server.org -u example -s ./test -d /home/example/public
    
To perform actions prior before deployment on the remote server, add a file
called td_before.sh to the root of your source folder. Likewise, to perform
actions after a deployment add a file called td_after.sh

To ignore files from deployment (locally and/or remote), add a file called
td_ignore.txt to the root of your source folder containing files and folders
that should be ignored.

For more information, see \033[0;36mhttps://github.com/kanduvisla/tiny-deploy\033[0m
';

    exit 1;
fi

echo "Starting deployment to remote server:
$SSH_USER@$SSH_HOST / $SSH_SOURCE --> $SSH_DESTINATION
"

function assert_exit_code {
    rc=$?;
    if [[ $rc != 0 ]]; then 
        echo "$1 (exit code $rc)" 1>&2;
        exit 1
    fi
}

# Perform remote actions before deployment:
if [ -x "$SSH_SOURCE"/td_before.sh ] && ssh -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" [ -x "$SSH_DESTINATION/td_before.sh" ]; then
    echo "Performing pre-deployment tasks"
    ssh -o StrictHostKeyChecking=no "$SSH_USER"@"$SSH_HOST" TD_ROOT="$SSH_DESTINATION" "$SSH_DESTINATION"/td_before.sh 
    assert_exit_code "Task failed"
fi;

# Create remote directory if it doesn't exist:
echo "Attempting to create remote directory if it doesn't exist"
ssh -o StrictHostKeyChecking=no "$SSH_USER"@"$SSH_HOST" mkdir -p "$SSH_DESTINATION"
assert_exit_code "Task failed"

# Attempt deployment with rsync:
if [ -r "$SSH_SOURCE"/td_ignore.txt ]; then
    # Ignore local files
    echo "Starting deployment with ignore list"
    rsync -avz --del --exclude-from "$SSH_SOURCE/td_ignore.txt" -e "ssh -o StrictHostKeyChecking=no" "$SSH_SOURCE"/ "$SSH_USER"@"$SSH_HOST":"$SSH_DESTINATION"
    assert_exit_code "Task failed"
    echo "Remove ignore list from remote host"
    ssh -o StrictHostKeyChecking=no "$SSH_USER"@"$SSH_HOST" rm "$SSH_DESTINATION"/td_ignore.txt
    assert_exit_code "Task failed"
else
    # Default deployment
    echo "Starting deployment"
    rsync -avz --del -e "ssh -o StrictHostKeyChecking=no" "$SSH_SOURCE"/ "$SSH_USER"@"$SSH_HOST":"$SSH_DESTINATION"
    assert_exit_code "Task failed"
fi

# Perform remote actions after deployment:
if [ -x "$SSH_SOURCE"/td_after.sh ]; then
    echo "Performing post-deployment tasks"
    ssh -o StrictHostKeyChecking=no "$SSH_USER"@"$SSH_HOST" TD_ROOT="$SSH_DESTINATION" "$SSH_DESTINATION"/td_after.sh
    assert_exit_code "Task failed"
fi;

# Everything went well ...
echo "Deployment complete"
exit 0;
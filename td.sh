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

# Perform remote actions before deployment:
if [ -e "$SSH_SOURCE"/td_before.sh ]; then
    ssh "$SSH_USER"@"$SSH_HOST" TD_ROOT="$SSH_DESTINATION" [ -e "$SSH_DESTINATION"/td_before.sh ] && "$SSH_DESTINATION"/td_before.sh 
fi;

# Create remote directory if it doesn't exist:
ssh "$SSH_USER"@"$SSH_HOST" mkdir -p "$SSH_DESTINATION"

# Attempt deployment with rsync:
if [ -e "$SSH_SOURCE"/td_ignore.txt ]; then
    # Ignore local files
    rsync -avz --del --exclude-from "$SSH_SOURCE/td_ignore.txt" -e ssh "$SSH_SOURCE"/ "$SSH_USER"@"$SSH_HOST":"$SSH_DESTINATION"
    ssh "$SSH_USER"@"$SSH_HOST" rm "$SSH_DESTINATION"/td_ignore.txt
else
    # Default deployment
    rsync -avz --del -e ssh "$SSH_SOURCE"/ "$SSH_USER"@"$SSH_HOST":"$SSH_DESTINATION"
fi

# Perform remote actions after deployment:
if [ -e "$SSH_SOURCE"/td_after.sh ]; then
    ssh "$SSH_USER"@"$SSH_HOST" TD_ROOT="$SSH_DESTINATION" "$SSH_DESTINATION"/td_after.sh
fi;
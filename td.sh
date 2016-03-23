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
    echo 'Tiny Deploy

Usage:
    ./td.sh -husd

Parameters:
    -h      The SSH Host to deploy to
    -u      The username to use
    -s      The source directory to deploy from
    -d      The target directory to deploy to

Example:
    ./td.sh -h server.org -u example -s ./test -d /home/example/public
';

    exit 1;
fi
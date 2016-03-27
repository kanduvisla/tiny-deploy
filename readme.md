# Tiny Deploy

_A small utility to deploy to a remote server_

---

## Installation

First, download it:

    curl -O https://raw.githubusercontent.com/kanduvisla/tiny-deploy/master/td.sh
    
To execute it:

    chmod +x td.sh
    ./td.sh
    
And if you want to really impress your friends: make it globally accessible:

    sudo mv td.sh /usr/local/bin/td
    td
    
That's it!

## Usage

    ./td.sh -h server.org -u example -s ./test -d /home/example/public
    
This example copies all files from `./test/*` to `example@server.org` in the folder `/home/example/public/`.

## Prerequisites

This script requires the program `rsync`to be installed on your system. Furthermore you need to know that the
authentication with the remote server is done with SSH keys. This means that your public key needs to be known
by the remote user@server that you are trying to deploy to. If your not familiar on how to do this, there are
various articles on the Internet that explain how to do this. [This one for example](https://kb.iu.edu/d/aews).

## Pre- and post-deployment tasks

To perform tasks before or after the deployment, add a shell script called `td_before.sh` and `td_after.sh` 
to the root of your source folder and make it executable. When present, this file will be executed after a 
deployment. In these files you will have a system variable called `$TD_ROOT` that represents the destination
of your deployment.

    # td_after.sh
    echo "Deployment finished in $TD_ROOT"

## Ignored files and folders

One thing you might want to control is a list if files that should not be deployed, or files on the server that
should not be removed. To ignore files locally or remote, add a file called `td_ignore.txt`  to the root of your 
source folder, in which you can include files and/or folders that should be ignored during deployment. 

    do_not_deploy.txt
    readme.txt
    exclude_dir/
    uploads/
    cache/
    
_Please note that due to rsyncs' nature, when a file or directory is added later on to `td_ignore.txt`, it's not
automatically deleted from the server as well. For this reason, when editing `td_ignore.txt`, some additional 
deleting on the remote server might be required._

## Disclaimer

Please note that the usage of this script is completely at your own risk and the author cannot be held 
responsible if anything breaks. If you encounter an issue, please report it or better yet: fix it and send a
pull request.
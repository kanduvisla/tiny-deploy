# Tiny Deploy

_A small utility to deploy to a remote server_

---

## Usage

    ./td.sh -h server.org -u example -s ./test -d /home/example/public
    
This example copies all files from `./test/*` to `example@server.org` in the folder `/home/example/public/`.

## Pre- and post-deployment tasks

To perform tasks before or after the deployment, add a shell script called `td_before.sh` and `td_after.sh` 
to the root of your source folder and make it executable. When present, this file will be executed after a 
deployment. In these files you will have a system variable called `$TD_ROOT` that represents the destination
of your deployment.
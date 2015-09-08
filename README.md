# Clone Bitbucket Repos


This script clones/pulls the latest code for all the repositories in a bitbucket team. You must have access to the repositories in order to clone them.


*Usage:*

    ./clone-bitbucket.sh -u {BITBUCKET_USERNAME} -t {BITBUCKET_TEAM}
    
By default the script will prompt you for your Bitbucket password or if you need to pass it in you can by passing using the `-p` flag.


For more info have a look at:

    ./clone-bitbucket.sh -h
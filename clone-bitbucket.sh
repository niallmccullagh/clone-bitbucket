#!/bin/bash
#Script to get all repositories under a team from bitbucket

script=$0
team=""
username=""
password=""
branches="no"

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

#Help function
function show_help {
    echo -e \\n"${BOLD}${script}.${NORM} clones/pulls the latest code for all the repositories in a bitbucket team. You must have access to the repositories in order to clone them."\\n
    echo -e "${REV}Basic usage:${NORM} ${BOLD}$script -u {username} -t {team}${NORM}"\\n
    echo -e "\nThe following command line switches are required:"
    echo -e "${REV}-u${NORM}  --Your bitbucket username."
    echo -e "${REV}-t${NORM}  --The name of the team you wish to clone all repos."
    echo -e "\nThe following command line switches are optional:"
    echo -e "${REV}-p${NORM}  --Your bitbucket password. If not supplied you will be prompted to enter."
    echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."
    echo -e "${REV}-b${NORM}  --Clone branches too."\\n
    exit 1
}

function validate_arguments {
    # Prompt for password if not set in the scripts arguments
    if [ -z $password ]; then
        echo "Please enter your password:"
        read -s password
    fi

    # Validate all args set
    if [ -z $team ] || [ -z $username ] || [ -z $password ]; then
        show_help
     fi
}

function get_repo_info {
    curl --fail -o repoinfo -su $username:$password https://api.bitbucket.org/1.0/users/$team 2>&1
    return_code=$?
    if [ $return_code != 0 ]; then
       tput setaf 1; echo "Failed getting repo list via curl: $return_code"; exit $return_code;
    fi
}

function process_repos {
    for repo_name in `jq '.repositories[].slug' repoinfo | sed s/\"//g | sort`
    do
        if [ ! -d "$repo_name" ]; then
            echo "Cloning " $repo_name
            git clone git@bitbucket.org:$username/$repo_name.git

            if [ $? != 0 ]; then
                tput setaf 1; echo "Failed cloning repo"; exit 1
            fi
            
            # Cloning all the branches?
            if [ $branches = "yes" ]; then 
                echo "Cloning branches..."
                cd $repo_name
	        for remote in `git branch -r  \
                               | grep -v HEAD \
                               | grep -v master`; do 
                    git branch --track $remote; 
                done
	        git pull --all 
                echo "Done cloning branches!"
                cd ..
            fi
        else
            echo "$repo_name already exists, pulling latest"

            pushd "$repo_name" > /dev/null
      
            git pull --all

            if [ $? != 0 ]; then
                tput setaf 1; echo "Failed pulling latest"; exit 1
            fi

            popd > /dev/null
        fi
        echo ""
    done
}

while getopts "h?t:u:p:b" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    t)  team=$OPTARG
        ;;
    u)  username=$OPTARG
        ;;
    p)  password=$OPTARG
	;;
    b)  branches="yes"
        ;;
    esac
done


validate_arguments
get_repo_info
process_repos

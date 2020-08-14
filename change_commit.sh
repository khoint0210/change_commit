#!/bin/bash
timestamp=$(date +"%m_%d_%H_%M")

function changeCommitHistory {
    echo "which value you want to hide"
    read value
    echo "regex:$value==>*******" >> .replace.txt
    bfg  --replace-text ".replace.txt"
    
    if [ ! $? -eq 0 ]; then
        echo "Something went wrong"
        exit
    fi
    
    rm -f .replace.txt
    
    echo "check file carefully before process and push to git"
    echo "Is it work correctly (y/n)"
    read isCorrect
    case $isCorrect in
        "y" | "yes")
            git reflog expire --expire=now --all && git gc --prune=now --aggressive
            echo "do you want to push the local git"
            read pushChange
            case $pushChange in
                "y" | "yes") 
                    git push -f
                ;;
                "n"|"no") 
                    echo "ok you can push latter but remember to push with -f flag due to we rewrite the history 🇻🇳"
                    exit
                ;;
            esac
        ;;
        "n"|"no") exit
        ;;
    esac
    
    git reflog expire --expire=now --all && git gc --prune=now --aggressive
    git add .
    git commit -m "$message"
    git push -f
}

which -s brew
if [[ $? != 0 ]] ; then
    echo "brew is not installed so installing..."
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "brew is installed"
fi

which -s bfg
if [[ $? != 0 ]] ; then
    echo "bfg is not installed so installing..."
    # Install bfg
    HOMEBREW_NO_AUTO_UPDATE=1 brew install bfg
else
    echo "bfg is installed"
fi

isError=true
while "$isError" = "true"
do
    echo "==========================="
    echo "Input folder path"
    echo "Must be from root folder patch, use pwd command at the folder of project : "
    read project_path
    
    if [ -d "$project_path" ]
    then
        isError=false
    else
        echo
        echo "Folder $project_path not exist"
        echo
        isError=true
    fi
done

cd $project_path
echo "Check the git remote to make sure you are at the right repo: "
echo
git remote -v
if [[ $? != 0 ]] ; then
    echo "you are not on the git repo"    
fi
echo "Is the repo correct (y/n)"
read isCorrect

case $isCorrect in
    "y" | "yes")
        echo "Making backup folder"
        cp -r "$project_path" "$project_path-backup-$timestamp"
        if [ ! $? -eq 0 ]; then
            echo "Something went wrong"
            exit
        fi
        changeCommitHistory
    ;;
    "n"|"no") exit
    ;;
esac



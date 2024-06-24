#!/bin/bash

PackageName="com.test.mini-game-framework-hot-update"
Version="0.0.1"
VersionStr="v$Version"

SCRIPT_DIR=$(dirname $(readlink -f $0))

function ReadNewVersion() {
    while true; do
        read -p "Enter a new version(latest:$Version): " NewVersion
        if [[ $NewVersion != $Version ]]; then
            if [[ $NewVersion =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                sed -i -e "s/Version=\"$Version\"/Version=\"$NewVersion\"/g" "$SCRIPT_DIR/PushPackage.sh"
                Version=$NewVersion
                VersionStr="v$Version"
                sed -i -e "s/\"version\"\s*:\s*\".*\"/\"version\": \"$Version\"/g" "$SCRIPT_DIR/Packages/$PackageName/package.json"
                break
            else
                echo "The new version is not in the correct format. Please try again."
            fi
        else
            echo "The new version cannot be the same as the old version. Please try again."
        fi
    done
}

function ExecuteGit() {
    git add "$SCRIPT_DIR/PushPackage.sh"
    git add "$SCRIPT_DIR/Packages/$PackageName/package.json"
    git commit -m "Update version to $VersionStr"
    git push
    git subtree split --prefix=Packages/$PackageName --branch upm
    git push origin upm
    git tag $VersionStr upm
    git push origin $VersionStr
}

function EndMain() {
    read -n 1 -p "Press any key to continue..."
    exit 1
}

ReadNewVersion

ExecuteGit

EndMain

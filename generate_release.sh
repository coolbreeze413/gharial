#!/bin/bash

GHARIAL_ROOT_DIR=$(pwd)

CURRENT_DATE=$(date +%d_%b_%Y)
CURRENT_TIME=$(date +"%H_%M_%S")

GH_OWNER="coolbreeze413"
GH_REPO="gharial"

#echo "$CURRENT_DATE"
#echo "$CURRENT_TIME"

# spinner stuff

set_spinner_snakey() {

    FRAME=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    FRAME_INTERVAL=0.1
}

set_spinner_infinity() {

    FRAME=("⚬" "⚭" "⚮" "⚯")
    FRAME_INTERVAL=0.25
}

set_spinner_rotatingbar() {

    FRAME=("-" "\\" "|" "/")
    FRAME_INTERVAL=0.25
}


CMD_WITH_SPINNER=
CMD_WITH_SPINNER_MSG=
execute_cmd_spinner() {

    tput civis -- invisible

    ${CMD_WITH_SPINNER} & pid=$!

    while ps -p $pid &> /dev/null; do
      echo -ne "\\r[   ] ${CMD_WITH_SPINNER_MSG} ..."

    for k in "${!FRAME[@]}"; do
        echo -ne "\\r[ ${FRAME[k]} ]"
        sleep $FRAME_INTERVAL
      done

    done

    echo -ne "\\r[ ✔ ] ${CMD_WITH_SPINNER_MSG}\\n"

    tput cnorm -- normal
}

# STEP 0: pull all remote repo changes in case we are running from an already cloned repo:
git pull


# STEP 1: generate dummy release:

RELEASE_NAME="gharial_release_${CURRENT_DATE}_${CURRENT_TIME}.sh"
RELEASES_DIR="${GHARIAL_ROOT_DIR}/release-artifacts"

echo
echo "creating new release artifact: $RELEASE_NAME"
echo

# pretend we are busy
CMD_WITH_SPINNER="sleep 3"
CMD_WITH_SPINNER_MSG="hard at work"
set_spinner_snakey
execute_cmd_spinner
echo $OUPUT

# pretend we are busy
CMD_WITH_SPINNER="sleep 3"
CMD_WITH_SPINNER_MSG="doing some more work"
set_spinner_rotatingbar
execute_cmd_spinner

# generate artifact
touch "$RELEASE_NAME"
echo "#!/bin/bash" >> "$RELEASE_NAME"
echo "" >> "$RELEASE_NAME"
echo "RELEASE_NAME=\"$RELEASE_NAME\"" >> "$RELEASE_NAME"
echo "" >> "$RELEASE_NAME"
echo "echo \"$RELEASE_NAME\"" >> "$RELEASE_NAME"
echo "" >> "$RELEASE_NAME"

# move the release artifact into the target dir:
mv -v "$RELEASE_NAME" "${RELEASES_DIR}/${RELEASE_NAME}"



# STEP 2: commit the artifact into new branch (for raising a PR)
DEFAULT_BRANCH_NAME="master"
RELEASES_BRANCH_NAME="releases/${CURRENT_DATE}/${CURRENT_TIME}"

echo
echo "commit release to a new branch and push upstream."
echo "        repo: ${GH_REPO}"
echo "      branch: ${RELEASES_BRANCH_NAME}"
echo "     release: ${RELEASES_DIR}/${RELEASE_NAME}"
echo

echo
echo -e "\n\n[-- 01 --]"
git checkout -b "$RELEASES_BRANCH_NAME"
echo -e "\n\n[-- 02 --]"
git status
echo -e "\n\n[-- 03 --]"
git add "${RELEASES_DIR}/${RELEASE_NAME}"
echo -e "\n\n[-- 04 --]"
git status
echo -e "\n\n[-- 05 --]"
git commit -m "[GHARIAL-DECEPTICON] add new release ${RELEASE_NAME}"
echo -e "\n\n[-- 06 --]"
git status
echo -e "\n\n[-- 07 --]"
git push -u origin "$RELEASES_BRANCH_NAME"
echo -e "\n\n[-- 08 --]"
git checkout "$DEFAULT_BRANCH_NAME"
echo -e "\n\n[-- 09 --]"
git pull
echo "[-- -- --]"
echo


exit 0

# STEP 3: wait for the release to be created TODO

# STEP -1: prerequisites
# assuming we cloned the repo using a PAT, the token is stored in .git/config file in plaintext
# what we want is the pattern: "url = https://TOKEN@github.com/OWNER/REPO[.git]"
# using regex:
regex_git_info_string="^.*url.*=.*https://(.+)@github.com/([^/]+)/(\S+)(\..*|\s+)"
git_info_string=`cat .git/config`

if [[ $git_info_string =~ $regex_git_info_string ]] ; then
    #echo "${BASH_REMATCH[1]}" # token
    #echo "${BASH_REMATCH[2]}" # username
    #echo "${BASH_REMATCH[3]}" # repo or repo.git

    GH_CONFIG_TOKEN=${BASH_REMATCH[1]}  # use the token from here
    GH_CONFIG_OWNER=${BASH_REMATCH[2]}  # we don't use this
    GH_CONFIG_REPO=${BASH_REMATCH[3]}   # we don't use this
fi

if [ -z "$GH_CONFIG_TOKEN" ] ; then
    echo
    echo "[ERROR] could not obtain PAT from local .git/config..."
    echo "did you clone the repo using a PAT?"
    echo "aborting."
    echo
    exit 1
fi


GH_LINUX_BIN_NAME="gh_2.3.0_linux_amd64"
if [ ! -d "$GH_LINUX_BIN_NAME" ] ; then

    if [ ! -f "${GH_LINUX_BIN_NAME}.tar.gz" ] ; then

        wget "https://github.com/cli/cli/releases/download/v2.3.0/${GH_LINUX_BIN_NAME}.tar.gz"

    fi

    tar -xf "${GH_LINUX_BIN_NAME}.tar.gz"

fi

# add to path:
GH_CLI_BIN_DIR_PATH="${PWD}/$GH_LINUX_BIN_NAME/bin"
export PATH="${GH_CLI_BIN_DIR_PATH}:${PATH}"

# test TODO more
TEST_GH_BIN_PATH=$(which gh)

if [ "$TEST_GH_BIN_PATH" != "$GH_CLI_BIN_DIR_PATH/gh" ] ; then

    echo
    echo "[ERROR] unexpected gh cli bin in path!"
    echo "expected: $GH_CLI_BIN_DIR_PATH"
    echo "     got: $TEST_GH_BIN_PATH"
    echo
    exit 1

fi

echo
gh --version
echo


# login
echo "$GH_CONFIG_TOKEN" | gh auth login --with-token
GH_LOGIN_STATUS=$?

if [ $GH_LOGIN_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh cli login using token failed: $GH_LOGIN_STATUS"
    echo
    exit 1

fi

echo -e "\n\n 1"
gh release view --json tagName,publishedAt

sleep 60
echo -e "\n\n 2"
gh release view --json tagName,publishedAt

sleep 60
echo -e "\n\n 3"
gh release view --json tagName,publishedAt

sleep 60
echo -e "\n\n 4"
gh release view --json tagName,publishedAt


#logout
echo "Y" | gh auth logout --hostname github.com

exit 0

#!/bin/bash

GHARIAL_ROOT_DIR=$(pwd)

CURRENT_DATE=$(date +%d_%b_%Y)
CURRENT_TIME=$(date +"%H_%M_%S")

GH_OWNER="coolbreeze413"
GH_REPO="gharial"

#echo "$CURRENT_DATE"
#echo "$CURRENT_TIME"

MODE_CREATE_PR_ONLY="false"
if [ "$#" == "1" ] ; then
    if [ "$1" == "create-pr" ] ; then
        MODE_CREATE_PR_ONLY="true"
    fi
fi

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
if [ "$MODE_CREATE_PR_ONLY" == "true" ] ; then
    # this mode has a gh action which is triggered with a PR from a 'releases/**' branch
    RELEASES_BRANCH_NAME="releases/${CURRENT_DATE}/${CURRENT_TIME}"
else
    # preven the gh action from triggering for standalone mode, so use a different branch name than above
    RELEASES_BRANCH_NAME="release-no-gha/${CURRENT_DATE}/${CURRENT_TIME}"
fi

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
git commit -m "[GHARIAL-DECEPTICON-COM] add new release ${RELEASE_NAME}"
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


# prerequisites
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


GH_CLI_VERSION="2.4.0"
GH_CLI_LINUX_BIN_NAME="gh_${GH_CLI_VERSION}_linux_amd64"
if [ ! -d "$GH_CLI_LINUX_BIN_NAME" ] ; then

    if [ ! -f "${GH_CLI_LINUX_BIN_NAME}.tar.gz" ] ; then

        wget "https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/${GH_CLI_LINUX_BIN_NAME}.tar.gz"

    fi

    tar -xf "${GH_CLI_LINUX_BIN_NAME}.tar.gz"

fi

# add to path:
GH_CLI_BIN_DIR_PATH="${PWD}/${GH_CLI_LINUX_BIN_NAME}/bin"
export PATH="${GH_CLI_BIN_DIR_PATH}:${PATH}"

TEST_GH_BIN_PATH=$(which gh)

if [ "$TEST_GH_BIN_PATH" != "${GH_CLI_BIN_DIR_PATH}/gh" ] ; then

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

echo
echo "gh cli login [OK]"
echo


# create PR
PR_TITLE="[GHARIAL-DECEPTICON-PR] Add new release: ${RELEASE_NAME}"
PR_BODY="auto create PR for adding a new release."
PR_HEAD="$RELEASES_BRANCH_NAME"
PR_BASE="$DEFAULT_BRANCH_NAME"
PR_URL=$(gh pr create --title "$PR_TITLE" \
             --body "$PR_BODY" \
             --head "$PR_HEAD" \
             --base "$PR_BASE" \
             )

GH_PR_CREATE_STATUS=$?

if [ $GH_PR_CREATE_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh pr create failed: $GH_PR_CREATE_STATUS"
    echo
    exit 1

fi

echo
echo "gh pr created [OK]"
echo "    $PR_URL"
echo


if [ "$MODE_CREATE_PR_ONLY" == "true" ] ; then

    # wait for the PR to be merged, and the release created...
    TIMEOUT=120
    RETRY_TIME=30
    CURR_TIME=0
    RELEASE_ASSET=""

    echo
    echo "waiting for release to be created by GHA"

    while [ $CURR_TIME -le $TIMEOUT ] ; do

        echo "[waiting]"

        RELEASE_ASSET=$(gh release view --json assets --jq '.assets[].name')
        
        if [ "$RELEASE_ASSET" == "$RELEASE_NAME" ] ; then
            break
        fi

        CURR_TIME=$(($CURR_TIME + $RETRY_TIME))
        sleep $RETRY_TIME

    done
    
    if [ "$RELEASE_ASSET" == "$RELEASE_NAME" ] ; then

        RELEASE_TAG=$(gh release view --json tagName --jq '.tagName')
        RELEASE_URL=$(gh release view --json url --jq '.url')
        RELEASE_ASSET_URL=$(gh release view --json assets --jq '.assets[].url')

        echo
        echo "release created by GHA [OK]"
        echo "        RELEASE_TAG: $RELEASE_TAG"
        echo "        RELEASE_URL: $RELEASE_URL"
        echo "      RELEASE_ASSET: $RELEASE_ASSET"
        echo "  RELEASE_ASSET_URL: $RELEASE_ASSET_URL"
        echo

    else

        echo "[ERROR]timed out waiting for new release creation!"
        echo "    check the GH Actions workflow for any errors!"

    fi

    # logout
    echo "Y" | gh auth logout --hostname github.com

    # checkout default branch and fetch
    git checkout "$DEFAULT_BRANCH_NAME"
    git fetch --tags origin

    # clean up branches
    # remove pointers to remote branches that don't exist
    git fetch --prune
    # delete local branches which don't have remotes (merged only)
    #git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
    # force delete local branches without remotes (unmerged)
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D

    # exit
    exit 0

fi


##########################################################################################
# # B: create PR using a HTTP POST request (DEPRECATED - FOR REFERENCE ONLY)
##########################################################################################
# #   REF: https://docs.github.com/en/rest/reference/pulls#create-a-pull-request
# #   B.1 : use curl to execute the HTTP POST (current approach)
# #   B.2 : use gh api directly to do the POST?

# # curl POST request:
# # REF: https://gist.github.com/subfuzion/08c5d85437d5d4f00e58
# # -X request method to use, default is GET
# # -H headers to supply with request
# #   for gh PR, we can also send token with header:
# #       -H "Authorization: Bearer $GITHUB_TOKEN"
# # -d send POST data
# #       JSON: 
# #           -d "{\"key1\":\"value1\", \"key2\":\"value2\"}"
# #           -d "@data.json"
# #       FORM URLENCODED
# #           -d "param1=value1&param2=value2"
# #           -d "@data.txt"
# #
# # general curl options
# # -s will silence progress meter of the request
# # -o /path/to/file will extract the response body and put it into a file
# #   if not used, then response body is output of curl
# # -w will extract the status code from the response
# # look at this for ref on how to get status code AND response both:
# #   https://stackoverflow.com/a/33900500/3379867

# GH_PR_TITLE="[GHARIAL-AUTO] Add new artifact: ${ARTIFACT_NAME}"
# GH_PR_BODY="We have a new artifact generated!\n\nWe would like to add this with this PR!\n"
# GH_PR_IS_DRAFT="false" # "true" if we want it to be a draft PR
# GH_PR_ISSUE="" # integer number referencing an issue to link PR with an issue


# # use the github token for authorization in the curl POST request.

# echo
# echo "obtained PAT, create PR using HTTP POST"
# echo

# RESPONSE=$(curl \
#     -s \
#     -w "GHARIAL_PR_HTTP_STATUS:%{http_code}" \
#     -X POST \
#     -H "Authorization: Bearer $GH_CONFIG_TOKEN" \
#     -H "Accept: application/vnd.github.v3+json" \
#     -d "{\"title\":\"${GH_PR_TITLE}\",\"head\":\"${PR_BRANCH_NAME}\",\"base\":\"${DEFAULT_BRANCH_NAME}\",\"body\":\"${GH_PR_BODY}\"}" \
#     "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/pulls")

# CURL_POST_STATUS=$?

# if [ $CURL_POST_STATUS -ne 0 ] ; then

#     echo
#     echo "curl failed with status = ${CURL_POST_STATUS}"
#     echo "    refer to below link for error details: "
#     echo "    https://everything.curl.dev/usingcurl/returns"
#     echo
#     exit 1

# fi


# # extract the actual reponse only:
# ACTUAL_RESPONSE=$(echo "$RESPONSE" | sed -e 's/^GHARIAL_PR_HTTP_STATUS:.*//')
# # store the curl response for debugging (add to .gitignore!)
# echo "$ACTUAL_RESPONSE" > curl_response.debug.log

# # extract the status code:
# GHARIAL_HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*GHARIAL_PR_HTTP_STATUS://')

# # extract the PR URL only if response code is ok (gh returns 201 created!):
# if [ $GHARIAL_HTTP_STATUS == "201" ] ; then
#     PR_URL=$(echo "$ACTUAL_RESPONSE" | jq '.html_url')
#     echo
#     echo "PR created : ${PR_URL}"
#     echo
# else
#     echo
#     echo "HTTP POST failed, with status: $GHARIAL_HTTP_STATUS"
#     echo
#     exit 1
# fi
##########################################################################################



# approve PR (optional) - need PAT of user other than the PAT used for creating PR!
# (not used in script flow!)



# merge PR (squash and merge as a single commit)
PR_MERGE_BODY="[GHARIAL-DECEPTICON-MERGE] auto merge latest PR for release"
PR_MERGE_RESPONSE=$(gh pr merge $PR_URL --auto --delete-branch --squash --body "$PR_MERGE_BODY")

GH_PR_MERGE_STATUS=$?

if [ $GH_PR_MERGE_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh pr merge failed: $GH_PR_MERGE_STATUS"
    echo "$GH_PR_MERGE_STATUS"
    echo
    exit 1

fi

echo
echo "gh merge [OK]"
echo



# pull in latest remote and switch to default branch now
git checkout "$DEFAULT_BRANCH_NAME"
git pull



# identify new tag version to use (semver)
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`
if [ -z $CURRENT_VERSION ] ; then
    
    CURRENT_VERSION="v0.0.0"
    NEW_VERSION="v1.0.0"

else

    # remove "v"
    CURRENT_VERSION_PARTS=$(echo "$CURRENT_VERSION" | sed 's/v//')
    # replace . with space so can split into an array
    CURRENT_VERSION_PARTS=(${CURRENT_VERSION_PARTS//./ })

    # get MAJOR, MINOR, PATCH
    V_MAJOR=${CURRENT_VERSION_PARTS[0]}
    V_MINOR=${CURRENT_VERSION_PARTS[1]}
    V_PATCH=${CURRENT_VERSION_PARTS[2]}

    # use custom logic to determine new MAJOR/MINOR/PATCH version numbers:
    # current we use a simple "increment minor"
    V_MINOR=$((V_MINOR+1))

    # remember to add "v"
    NEW_VERSION="v${V_MAJOR}.${V_MINOR}.${V_PATCH}"

fi

echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "NEW_VERSION=$NEW_VERSION"



# create release
RELEASE_NOTES_FILE="${PWD}/gh_release_changelog_tmp"
# if file exists, empty contents, else create file all in one! REF: https://askubuntu.com/a/549672
: > "$RELEASE_NOTES_FILE"
echo "placeholder notes content for notes or changelog !!" >> "$RELEASE_NOTES_FILE"
echo "blah blah notes for ${RELEASE_NAME}" >> "$RELEASE_NOTES_FILE"

RELEASE_TITLE="release ${NEW_VERSION} : ${RELEASE_NAME}"

GH_RELEASE_URL=$(gh release create --title "$RELEASE_TITLE" \
                                        --notes-file "$RELEASE_NOTES_FILE" \
                                        --target "$DEFAULT_BRANCH_NAME" \
                                        "$NEW_VERSION" \
                                        "${RELEASES_DIR}/${RELEASE_NAME}" )

GH_RELEASE_STATUS=$?


if [ $GH_RELEASE_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh release create failed: $GH_RELEASE_STATUS"
    echo "$GH_RELEASE_URL"
    echo
    exit 1

fi


# wait for some time before querying the latest release (takes some time to update in gh)
sleep 10
RELEASE_TAG=$(gh release view --json tagName --jq '.tagName')
RELEASE_URL=$(gh release view --json url --jq '.url')
RELEASE_ASSET=$(gh release view --json assets --jq '.assets[].name')
RELEASE_ASSET_URL=$(gh release view --json assets --jq '.assets[].url')

echo
echo "release created by GHA [OK]"
echo "        RELEASE_TAG: $RELEASE_TAG"
echo "        RELEASE_URL: $RELEASE_URL"
echo "      RELEASE_ASSET: $RELEASE_ASSET"
echo "  RELEASE_ASSET_URL: $RELEASE_ASSET_URL"
echo



# fetch the new tags after release:
git fetch --tags origin



# clean up branches
# remove pointers to remote branches that don't exist
git fetch --prune
# delete local branches which don't have remotes (merged only)
#git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
# force delete local branches without remotes (unmerged)
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D



# logout
echo "Y" | gh auth logout --hostname github.com

exit 0

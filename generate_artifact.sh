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


# STEP 0: pull all remote repo changes in case we are running from an already cloned repo:
git pull


# STEP 1: generate dummy artifact:

ARTIFACT_NAME="gharial_artifact_${CURRENT_DATE}_${CURRENT_TIME}.sh"
ARTIFACTS_DIR="${GHARIAL_ROOT_DIR}/artifacts"

echo
echo "creating new artifact: $ARTIFACT_NAME"
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
touch "$ARTIFACT_NAME"
echo "#!/bin/bash" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "ARTIFACT_NAME=\"$ARTIFACT_NAME\"" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "echo \"$ARTIFACT_NAME\"" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"

# move the artifact into the target dir:
mv -v "$ARTIFACT_NAME" "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"



# STEP 2: commit the artifact into new branch (for raising a PR)
DEFAULT_BRANCH_NAME="master"
PR_BRANCH_NAME="br_package_${CURRENT_DATE}_${CURRENT_TIME}"

echo
echo "commit artifact to a new branch and push upstream."
echo "        repo: ${GH_REPO}"
echo "      branch: ${PR_BRANCH_NAME}"
echo "    artifact: ${ARTIFACTS_DIR}/${ARTIFACT_NAME}"
echo

echo
echo "[-- 01 --]"
git checkout -b "$PR_BRANCH_NAME"
echo "[-- 02 --]"
git status
echo "[-- 03 --]"
git add "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"
echo "[-- 04 --]"
git status
echo "[-- 05 --]"
git commit -m "add new artifact ${ARTIFACT_NAME}"
echo "[-- 06 --]"
git status
echo "[-- 07 --]"
git push -u origin "$PR_BRANCH_NAME"
echo "[-- 08 --]"
git checkout "$DEFAULT_BRANCH_NAME"
echo "[-- 09 --]"
git pull
echo "[-- -- --]"
echo


# STEP 3: create PR for the new branch once it is upstream
# A: create PR using the CLI (needs extra gh cli installed)
#   REF: https://cli.github.com/manual/gh_pr_create

PR_TITLE="[GHARIAL-AUTO] Add new artifact: ${ARTIFACT_NAME}"
PR_BODY="PR for adding a new artifact."

PR_URL=$(gh pr create --title "$PR_TITLE" \
             --body "$PR_BODY" \
             --head "$PR_BRANCH_NAME" \
             --base "$DEFAULT_BRANCH_NAME" \
             )

GH_PR_STATUS=$?

if [ $GH_PR_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh pr create failed: $GH_PR_STATUS"
    echo
    exit 1

fi

echo
echo "gh pr created ok:"
echo "    $PR_URL"
echo

##########################################################################################
# # B: create PR using a HTTP POST request (DEPRECATED)
##########################################################################################
# #   REF: https://docs.github.com/en/rest/reference/pulls#create-a-pull-request
# #   B.1 : use curl to execute the HTTP POST (current approach)
# #   B.2 : use python script to create the PR ?

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


# STEP 4: merge PR from the new branch to default
MERGE_BODY="[GHARIAL-AUTO] automatically merging latest PR for artifact"

GH_MERGE_RESPONSE=$(gh pr merge $PR_URL --auto --delete-branch --squash --body "$MERGE_BODY")
GH_MERGE_STATUS=$?

if [ $GH_MERGE_STATUS -ne 0 ] ; then

    echo
    echo "[ERROR] gh pr create failed: $GH_PR_STATUS"
    echo
    exit 1

fi

echo
echo "gh merge ok:"
echo "$GH_MERGE_RESPONSE"
echo


#logout
echo "Y" | gh auth logout --hostname github.com

exit 0

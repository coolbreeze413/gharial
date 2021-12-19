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

git checkout -b "$PR_BRANCH_NAME"
git status
git add "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"
git status
git commit -m "add new artifact ${ARTIFACT_NAME}"
git status
git push -u origin "$PR_BRANCH_NAME"
git checkout "$DEFAULT_BRANCH_NAME"
git pull


# STEP 3: create PR for the new branch once it is upstream
# A: create PR using the CLI (needs extra gh cli installed)
#   REF: https://cli.github.com/manual/gh_pr_create
# B: create PR using a HTTP POST request
#   REF: https://docs.github.com/en/rest/reference/pulls#create-a-pull-request
#   B.1 : use curl to execute the HTTP POST (current approach)
#   B.2 : use python, FUTURE TODO.
#           an easier way would be to use a python script to generate the json, AND POST the request AND verify the response
#           AND extract the GH PAT from the config file, assuming that we used the token while cloning the repo
#           python3 generate_gh_pr --gh_pr_owner="" --gh_pr_repo="" --gh_pr_title="" --gh_pr_body="" --gh_pr_head="" gh_pr_base="" gh_pr_is_draft="" gh_pr_issue=""


# curl POST request:
# REF: https://gist.github.com/subfuzion/08c5d85437d5d4f00e58
# -X request method to use, default is GET
# -H headers to supply with request
#   for gh PR, we can also send token with header:
#       -H "Authorization: Bearer $GITHUB_TOKEN"
# -d send POST data
#       JSON: 
#           -d "{\"key1\":\"value1\", \"key2\":\"value2\"}"
#           -d "@data.json"
#       FORM URLENCODED
#           -d "param1=value1&param2=value2"
#           -d "@data.txt"
#
# general curl options
# -s will silence progress meter of the request
# -o /path/to/file will extract the response body and put it into a file
#   if not used, then response body is output of curl
# -w will extract the status code from the response
# look at this for ref on how to get status code AND response both:
#   https://stackoverflow.com/a/33900500/3379867

GH_PR_TITLE="[GHARIAL-AUTO] Add new artifact: ${ARTIFACT_NAME}"
GH_PR_BODY="We have a new artifact generated!\n\nWe would like to add this with this PR!\n"
GH_PR_IS_DRAFT="false" # "true" if we want it to be a draft PR
GH_PR_ISSUE="" # integer number referencing an issue to link PR with an issue


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
    echo "aborting PR step - create the PR manually..."
    echo
    exit 1
fi

# use the github token for authorization in the curl POST request.

echo
echo "create PR using HTTP POST"
echo

RESPONSE=$(curl \
    -s \
    -w "GHARIAL_PR_HTTP_STATUS:%{http_code}" \
    -X POST \
    -H "Authorization: Bearer $GH_CONFIG_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"title\":\"${GH_PR_TITLE}\",\"head\":\"${PR_BRANCH_NAME}\",\"base\":\"${DEFAULT_BRANCH_NAME}\",\"body\":\"${GH_PR_BODY}\"}" \
    "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/pulls")

CURL_POST_STATUS=$?

if [ $CURL_POST_STATUS -ne 0 ] ; then

    echo
    echo "curl failed with status = ${CURL_POST_STATUS}"
    echo "    refer to below link for error details: "
    echo "    https://everything.curl.dev/usingcurl/returns"
    echo
    exit 1

fi


# extract the actual reponse only:
ACTUAL_RESPONSE=$(echo "$RESPONSE" | sed -e 's/^GHARIAL_PR_HTTP_STATUS:.*//')
echo "$ACTUAL_RESPONSE" > curl_response.debug.log

# extract the status code:
GHARIAL_HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*GHARIAL_PR_HTTP_STATUS://')

# extract the PR URL only if response code is ok (gh returns 201 created!):
if [ $GHARIAL_HTTP_STATUS == "201" ] ; then
    PR_URL=$(echo "$ACTUAL_RESPONSE" | jq '.html_url')
    echo
    echo "PR created : ${PR_URL}"
    echo
else
    echo
    echo "HTTP POST failed, with status: $GHARIAL_HTTP_STATUS"
    echo
    exit 1
fi


exit 0

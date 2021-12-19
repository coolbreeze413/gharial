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


CMD_WITH_SPINNER="sleep 3"
CMD_WITH_SPINNER_MSG="hard at work creating the artifact [trust me!]"
set_spinner_snakey
execute_cmd_spinner
echo $OUPUT

CMD_WITH_SPINNER="sleep 3"
CMD_WITH_SPINNER_MSG="doing some more work [really!]"
set_spinner_infinity
execute_cmd_spinner


touch "$ARTIFACT_NAME"
echo "#!/bin/bash" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "echo \"$ARTIFACT_NAME\"" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"

# move the artifact into the target dir:
mv "$ARTIFACT_NAME" "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"



# STEP 2: commit the artifact into new branch
DEFAULT_BRANCH_NAME="master"
NEW_BRANCH_NAME="br_package_${CURRENT_DATE}_${CURRENT_TIME}"
git checkout -b "$BRANCH_NAME"
git status
git add "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"
git status
git commit -m "add new artifact ${ARTIFACT_NAME}"
git status
git push -u origin "$NEW_BRANCH_NAME"
git checkout "$DEFAULT_BRANCH_NAME"
git pull


# STEP 3: create PR for the new branch once it is upstream
# A: create PR using the CLI (needs extra gh cli installed)
#   REF: https://cli.github.com/manual/gh_pr_create
# B: create PR using a HTTP POST request
#   REF: https://docs.github.com/en/rest/reference/pulls#create-a-pull-request

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

GH_PR_TITLE="Add new artifact: ${ARTIFACT_NAME}"
GH_PR_BODY="We have a new artifact generated!\n\nWe would like to add this with this PR!\n"
GH_PR_IS_DRAFT="false" # "true otherwise"
GH_PR_ISSUE="" # integer number referencing the issue

# an easier way would be to use a python script to generate the json, AND POST the request AND verify the response
# python3 generate_gh_pr --gh_pr_owner="" --gh_pr_repo="" --gh_pr_title="" --gh_pr_body="" --gh_pr_head="" gh_pr_base="" gh_pr_is_draft="" gh_pr_issue=""
# FUTURE TODO.

curl \
    -w \
    -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"title\":\"${GH_PR_TITLE}\",\"head\":\"${NEW_BRANCH_NAME}\",\"base\":\"${DEFAULT_BRANCH_NAME}\",\"body\":\"$GH_PR_BODY\"}" \
    https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/pulls

CURL_POST_STATUS=$?
echo
echo "CURL_POST_STATUS=$CURL_POST_STATUS"
echo


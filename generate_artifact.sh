#!/bin/bash

GHARIAL_ROOT_DIR=$(pwd)

CURRENT_DATE=$(date +%d_%b_%Y)
CURRENT_TIME=$(date +"%H_%M_%S")

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



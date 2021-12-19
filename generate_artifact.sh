#!/bin/bash

GHARIAL_ROOT_DIR=$(pwd)

CURRENT_DATE=$(date +%d_%b_%Y)
CURRENT_TIME=$(date +"%H_%M_%S")

echo "$CURRENT_DATE"
echo "$CURRENT_TIME"

# generate dummy artifact:

ARTIFACT_NAME="gharial_artifact_${CURRENT_DATE}_${CURRENT_TIME}.sh"
ARTIFACTS_DIR="${GHARIAL_ROOT_DIR}/artifacts"

touch "$ARTIFACT_NAME"
echo "#!/bin/bash" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"
echo "echo \"$ARTIFACT_NAME\"" >> "$ARTIFACT_NAME"
echo "" >> "$ARTIFACT_NAME"

# move the artifact into the target dir:
mv "$ARTIFACT_NAME" "${ARTIFACTS_DIR}/${ARTIFACT_NAME}"



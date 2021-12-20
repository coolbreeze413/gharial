#!/bin/bash

GHARIAL_ROOT_DIR=$(pwd)
GHARIAL_CONDA_INSTALL_DIR="$GHARIAL_ROOT_DIR/conda"
GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX="$GHARIAL_ROOT_DIR/conda/envs/gharial"
GHARIAL_CONDA_ENV__GHARIAL__ENV_YAML="$GHARIAL_ROOT_DIR/environment.yml"
GHARIAL_CONDA_ENV__GHARIAL__REQ_TXT="$GHARIAL_ROOT_DIR/requirements.txt"


# use this when explicitly requested for a fresh installation!
# check for existing conda install
# if [ -d "$GHARIAL_CONDA_INSTALL_DIR" ] ; then

#     # clean it up
#     echo ""
#     echo "[>> GHARIAL <<] clean up existing conda installation in:" 
#     echo "    $GHARIAL_CONDA_INSTALL_DIR"
#     echo ""

#     rm -rf "$GHARIAL_CONDA_INSTALL_DIR"

# fi



# check for existing conda install
if [ -d "$GHARIAL_CONDA_INSTALL_DIR" ] ; then

    # already exists
    echo ""
    echo "[>> GHARIAL <<] reusing existing conda install in:" 
    echo "    $GHARIAL_CONDA_INSTALL_DIR"
    echo ""

    # setup the conda installation path
    setup_local_conda_install_paths "$GHARIAL_CONDA_INSTALL_DIR"

else

    # conda install dir does not exist
    echo ""
    echo "[>> GHARIAL <<] conda installation does not exist, create new conda install"
    echo ""

    # setup new conda install
    setup_local_conda_install "$GHARIAL_CONDA_INSTALL_DIR"

fi



# check for existing conda environment
if [ -d "$GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX" ] ; then

    # already exists, nothing do further to setup a new env in development mode
    echo ""
    echo "[>> GHARIAL <<] reusing existing GHARIAL conda env in:" 
    echo "    $GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"
    echo ""

else

    # conda env dir does not exist
    echo ""
    echo "[>> GHARIAL <<] conda env does not exist, create new GHARIAL conda env at:"
    echo "    $GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"
    echo ""

    # create the GHARIAL conda environment
    create_local_conda_env "$GHARIAL_CONDA_INSTALL_DIR" "$GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX" "$GHARIAL_CONDA_ENV__GHARIAL__ENV_YAML"

    # test the gharial conda env to check if it looks good
    test_local_conda_env "$GHARIAL_CONDA_INSTALL_DIR" "$GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"

    if [ ! $? == 0 ] ; then

        echo
        echo "[>> GHARIAL <<] ERROR: test for gharial conda env failed, aborting."
        echo
        exit 1

    fi

fi


# activate the gharial conda env
echo
echo "[>> gharial <<] activate gharial conda env"
echo "  $GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"
echo

conda activate "$GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"


which git
which jq
which curl



# deactivate the gharial conda env
echo
echo "[>> gharial <<] deactivate gharial conda env"
echo "  $GHARIAL_CONDA_ENV__GHARIAL__ENV_PREFIX"
echo

conda deactivate

exit 0
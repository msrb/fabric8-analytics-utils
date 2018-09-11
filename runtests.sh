#!/bin/bash

set -e
set -x

COVERAGE_THRESHOLD=90

# set up terminal colors
RED=$(tput bold && tput setaf 1)
GREEN=$(tput bold && tput setaf 2)
YELLOW=$(tput bold && tput setaf 3)
NORMAL=$(tput sgr0)


echo "Create Virtualenv for Python deps ..."
function prepare_venv() {
    VIRTUALENV=$(which virtualenv)
    if [ $? -eq 1 ]
    then
        # python34 which is in CentOS does not have virtualenv binary
        VIRTUALENV=$(which virtualenv-3)
    fi

    ${VIRTUALENV} -p python3 venv && source venv/bin/activate
    if [ $? -ne 0 ]
    then
        printf "%sPython virtual environment can't be initialized%s" "${RED}" "${NORMAL}"
        exit 1
    fi
    pip install -U pip
    python3 "$(which pip3)" install -r requirements.txt

}

[ "$NOVENV" == "1" ] || prepare_venv || exit 1

$(which pip3) install pytest
$(which pip3) install pytest-cov

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=`pwd` python3 "$(which pytest)" --cov=f8a_utils/ --cov-report term-missing --cov-fail-under=$COVERAGE_THRESHOLD -vv tests/
printf "%stests passed%s\n\n" "${GREEN}" "${NORMAL}"


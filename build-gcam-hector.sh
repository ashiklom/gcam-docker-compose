#!/usr/bin/env bash

HECTOR_VERSION=$1
GCAMROOT="../gcam-core"
CWD=$(pwd)

cd $GCAMROOT || exit 1

if [[ $HECTOR_VERSION = "default" ]]
then
    HECTOR_REV="origin/gcam-integration"
    git checkout master || exit 1
    git submodule update
else
    HECTOR_REV=$HECTOR_VERSION
    git checkout ans/feature/hector-update || exit 1
    git submodule update
    # Checkout Hector version
    cd "cvs/objects/climate/source/hector" || exit 1
    git checkout "$HECTOR_REV" || exit 1
fi

# Return to Docker directory
cd "$CWD" || exit 1

# Build image
docker build \
    -f "$CWD/Dockerfile-gcam"\
    --build-arg NCPU=4 \
    --tag ashiklom/gcam-hector:"$HECTOR_VERSION"\
    "$GCAMROOT"

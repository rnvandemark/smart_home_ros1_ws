#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

WS_CLEAN=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --clean)
            WS_CLEAN=1; shift ;;
        *)
            echo "WARNING: Unknown parameter passed: $1"; shift ;;
    esac
done

pushd "$SCRIPT_DIR" >/dev/null 2>&1
if [[ WS_CLEAN -eq 1 ]]; then
	echo "Cleaning out build products..."
	rm -rf devel_isolated/ build_isolated/ install_isolated/
fi
catkin_make_isolated --install --force-cmake
popd >/dev/null 2>&1

#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

WS_CLEAN=0
DO_ARDUINO=0
VERBOSE=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --clean)
            WS_CLEAN=1; shift ;;
        --ard)
            DO_ARDUINO=1; shift ;;
        -v | --verbose)
            VERBOSE=1; shift ;;
        *)
            echo "WARNING: Unknown parameter passed: $1"; shift ;;
    esac
done

pushd "$SCRIPT_DIR" >/dev/null 2>&1

BUILD_CMD="catkin build --force-cmake"
if [[ WS_CLEAN -eq 1 ]]; then
    BUILD_CMD="$BUILD_CMD --pre-clean"
fi
if [[ VERBOSE -eq 1 ]]; then
    BUILD_CMD="$BUILD_CMD --verbose"
fi
if [[ DO_ARDUINO -eq 0 ]]; then
    BUILD_CMD="$BUILD_CMD smart_home_msgs smart_home_hub"
fi

catkin config --install
eval "$BUILD_CMD"

# Upload the compiled program to the traffic light arduino
if [[ DO_ARDUINO -eq 1 ]]; then
    # The arduino-cmake project is not completely stable... resort to this
    PROCESSOR="${PROCESSOR:-atmega2560}"
    PORT="${PORT:-/dev/ttyUSB0}"
    BAUD="${BAUD:-115200}"
    AVR_DIR="${ARDUINO_SDK_PATH:-/usr/share/arduino-1.8.13}/hardware/tools/avr"
    eval "${AVR_DIR}/bin/avrdude -C/${AVR_DIR}/etc/avrdude.conf -v -p${PROCESSOR} -cwiring -P${PORT} -b${BAUD} -D -Uflash:w:./devel/share/smart_home_arduino/traffic_light_runner.hex"
fi

popd >/dev/null 2>&1

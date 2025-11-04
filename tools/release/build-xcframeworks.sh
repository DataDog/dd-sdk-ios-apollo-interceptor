#!/bin/zsh

# Usage:
# $ ./tools/release/build-xcframeworks.sh -h
# Builds XCFrameworks from the specified repository and exports them to the designated output directory.

# Options:
#   --repo-path: The path to the root of the repository.
#   --ios: Includes iOS platform slices in the exported XCFrameworks.
#   --tvos: Includes tvOS platform slices in the exported XCFrameworks.
#   --output-path: The path to the output directory where XCFrameworks will be stored.

set -eo pipefail
source ./tools/utils/argparse.sh
source ./tools/utils/echo-color.sh

set_description "Builds XCFrameworks from the specified repository and exports them to the designated output directory."
define_arg "repo-path" "" "The path to the root of the repository." "string" "true"
define_arg "ios" "false" "Includes iOS platform slices in the exported XCFrameworks." "store_true"
define_arg "tvos" "false" "Includes tvOS platform slices in the exported XCFrameworks." "store_true"
define_arg "output-path" "" "The path to the output directory where XCFrameworks will be stored." "string" "true"

check_for_help "$@"
parse_args "$@"

REPO_PATH=$(realpath "$repo_path")
PRODUCT_NAME="DatadogApollo"
SCHEME_NAME="DatadogApollo"

echo_info "Clean '$REPO_PATH' with 'git clean -fxd'"
cd "$REPO_PATH" && git clean -fxd && cd -

echo_info "Create '$output_path'"
rm -rf "$output_path" && mkdir -p "$output_path"

XCFRAMEWORKS_OUTPUT=$(realpath "$output_path")
ARCHIVES_TEMP_OUTPUT="$XCFRAMEWORKS_OUTPUT/archives"

archive() {
    local destination="$1"
    local archive_path="$2"
    local sdk="$3"

    echo_subtitle2 "➔ Archive '$PRODUCT_NAME' for destination: '$destination'"

    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -destination "$destination" \
        -archivePath "$archive_path" \
        -sdk "$sdk" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ONLY_ACTIVE_ARCH=NO \
        | xcbeautify || true  # Continue on beautify errors

    echo_succ "The archive was created successfully at '$archive_path.xcarchive'"
}

build_xcframework() {
    local platform="$1"
    xcoptions=()

    echo_subtitle2 "Build '$PRODUCT_NAME.xcframework' using platform='$platform'"

    if [[ $platform == *"iOS"* ]]; then
        echo_info "▸ Archive $PRODUCT_NAME iOS"

        archive "generic/platform=iOS" "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/ios" "iphoneos"
        xcoptions+=(-archive "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/ios.xcarchive" -framework "$PRODUCT_NAME.framework")

        archive "generic/platform=iOS Simulator" "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/ios-simulator" "iphonesimulator"
        xcoptions+=(-archive "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/ios-simulator.xcarchive" -framework "$PRODUCT_NAME.framework")
    fi

    if [[ $platform == *"tvOS"* ]]; then
        echo_info "▸ Archive $PRODUCT_NAME tvOS"

        archive "generic/platform=tvOS" "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/tvos" "appletvos"
        xcoptions+=(-archive "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/tvos.xcarchive" -framework "$PRODUCT_NAME.framework")

        archive "generic/platform=tvOS Simulator" "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/tvos-simulator" "appletvsimulator"
        xcoptions+=(-archive "$ARCHIVES_TEMP_OUTPUT/$PRODUCT_NAME/tvos-simulator.xcarchive" -framework "$PRODUCT_NAME.framework")
    fi

    xcodebuild -create-xcframework ${xcoptions[@]} -output "$XCFRAMEWORKS_OUTPUT/$PRODUCT_NAME.xcframework" | xcbeautify || true

    echo_succ "The '$PRODUCT_NAME.xcframework' was created successfully in '$XCFRAMEWORKS_OUTPUT'"
}

echo_info "cd '$REPO_PATH'"
cd $REPO_PATH

# Select PLATFORMS to build ('iOS' | 'tvOS' | 'iOS,tvOS')
PLATFORMS=""
[[ "$ios" == "true" ]] && PLATFORMS+="iOS"
[[ "$tvos" == "true" ]] && { [ -n "$PLATFORMS" ] && PLATFORMS+=","; PLATFORMS+="tvOS"; }

echo_info "Building xcframeworks"
echo_info "▸ REPO_PATH = '$REPO_PATH'"
echo_info "▸ ARCHIVES_TEMP_OUTPUT = '$ARCHIVES_TEMP_OUTPUT'"
echo_info "▸ XCFRAMEWORKS_OUTPUT = '$XCFRAMEWORKS_OUTPUT'"
echo_info "▸ PLATFORMS = '$PLATFORMS'"

# Build DatadogApollo XCFramework
build_xcframework "$PLATFORMS"

# Cleanup temporary archives
rm -rf "$ARCHIVES_TEMP_OUTPUT"

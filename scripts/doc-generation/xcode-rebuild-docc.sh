#!/usr/bin/env bash
set -eo pipefail

main() {
    MAPBOXMAPS_PATH=${MAPBOXMAPS_PATH:-"."}
    DOCC_ARCHIVE_PATH=${DOCC_ARCHIVE_PATH:-"$TARGET_BUILD_DIR/MapboxMaps.doccarchive"}
    OTHER_DOCC_FLAGS_UNIFIED=${OTHER_DOCC_FLAGS_UNIFIED:-""}

    generateDependenciesFile
    # Generate documentation only for certain configuration:
    # - docbuild: Build Documentation action
    # - build with RUN_DOCUMENTATION_COMPILER=YES: Build action with option to build documentation during build
    if [[ ! ( "$ACTION" == "docbuild" || ( "$RUN_DOCUMENTATION_COMPILER" == "YES" && "$ACTION" == "build" )) ]]; then
        echo "Skipping docc generation"
        exit 0
    fi

    if [[ ! "$OTHER_DOCC_FLAGS" == *"--help"* ]]; then
        echo "Skipping docc generation cause OTHER_DOCC_FLAGS does not contain --help"
        exit 0
    fi

    generateSymbolGraphs

# shellcheck disable=SC2086
    docc convert "$SCRIPT_INPUT_FILE_0" \
        --emit-lmdb-index \
        --ide-console-output --emit-fixits \
        --fallback-display-name MapboxMaps \
        --fallback-bundle-identifier com.mapbox.MapboxMaps \
        --fallback-bundle-version 1 \
        --diagnostics-file "$SCRIPT_OUTPUT_FILE_0" \
        --output-dir "$DOCC_ARCHIVE_PATH" \
        --additional-symbol-graph-dir "$BUILT_PRODUCTS_DIR/symbol-graphs" $OTHER_DOCC_FLAGS_UNIFIED
    cp "$SCRIPT_OUTPUT_FILE_0" "$TARGET_TEMP_DIR/MapboxMaps-diagnostics.json"
}

generateSymbolGraphs() {
    triplet="${NATIVE_ARCH}-${LLVM_TARGET_TRIPLE_VENDOR}-${LLVM_TARGET_TRIPLE_OS_VERSION}${LLVM_TARGET_TRIPLE_SUFFIX}"
    SYMBOL_GRAPH_DIR="$BUILT_PRODUCTS_DIR/symbol-graphs"

    CLANG_OUTPUT_DIR="$SYMBOL_GRAPH_DIR/clang/${triplet}"
    SWIFTEXTRACT_OUTPUT_DIR="$SYMBOL_GRAPH_DIR/swift/$triplet"
    mkdir -p "$CLANG_OUTPUT_DIR"
    mkdir -p "$SWIFTEXTRACT_OUTPUT_DIR"

    SYMBOLGRAPH_TOOL="time swift symbolgraph-extract -sdk $(xcrun --sdk "$SDK_NAME" --show-sdk-path) -target $triplet -skip-inherited-docs"
    clangExtractApi() {
        local moduleName="$1"
        local productName=${2:-$moduleName}

        FRAMEWORK_PATH="$BUILT_PRODUCTS_DIR/$moduleName.framework"

        time xcrun --sdk "$SDK_NAME" clang -extract-api -x objective-c-header -o "$CLANG_OUTPUT_DIR/$moduleName.symbols.json" \
            -I"${FRAMEWORK_PATH}/Headers" \
            "${FRAMEWORK_PATH}/Headers/"* \
            -F "${BUILT_PRODUCTS_DIR}" \
            --product-name="$productName"
    }

    # Export symbol graphs for MapboxCommon
    echo "Exporting symbol graphs for MapboxCommon"
    clangExtractApi "MapboxCommon"

    $SYMBOLGRAPH_TOOL -module-name "MapboxCommon" -output-dir "$SWIFTEXTRACT_OUTPUT_DIR" -F "$BUILT_PRODUCTS_DIR"

    # Exporting symbol graphs for MapboxCoreMaps
    echo "Exporting symbol graphs for MapboxCoreMaps"
    clangExtractApi "MapboxCoreMaps" "MapboxMaps"

    # Force the product name to be MapboxMaps to merge into MapboxMaps doc
    sed -i '' 's/MapboxCoreMaps/MapboxMaps/g' "$CLANG_OUTPUT_DIR/MapboxCoreMaps.symbols.json"

    $SYMBOLGRAPH_TOOL -module-name "MapboxCoreMaps" -output-dir "$SWIFTEXTRACT_OUTPUT_DIR" -F "$BUILT_PRODUCTS_DIR"

    # Rename the swift symbol-graph module name to MapboxMaps to merge into MapboxMaps doc.
    sed -i '' 's/MapboxCoreMaps/MapboxMaps/g' "$SWIFTEXTRACT_OUTPUT_DIR/MapboxCoreMaps.symbols.json"

    # Exporting symbol graphs for Turf
    $SYMBOLGRAPH_TOOL -module-name "Turf" -output-dir "$SWIFTEXTRACT_OUTPUT_DIR" -F "$TARGET_BUILD_DIR"

    # Exporting symbol graphs for MapboxMaps
    $SYMBOLGRAPH_TOOL -module-name "MapboxMaps" -output-dir "$SWIFTEXTRACT_OUTPUT_DIR" -F "$TARGET_BUILD_DIR"
}

# Generate a dependency file to support incremental builds
# That means that we provide a list of files (in Makefile format) that are used to generate the output file.
# As long as none of the files in the list changes, the script would not be executed again.
generateDependenciesFile() {
    DEPENDENCIES_FILE="$DERIVED_FILES_DIR/MapboxMapsCustomDocumentation.d"

    echo -n "$SCRIPT_OUTPUT_FILE_0 : " > "$DEPENDENCIES_FILE"
    SOURCES=$(find "$SRCROOT/$MAPBOXMAPS_PATH/Sources/MapboxMaps" "$DERIVED_FILES_DIR" -name "*.swift" -print0 | xargs -0)
    DOCS=$(find "$SCRIPT_INPUT_FILE_0" -type f -print0 | sed 's/ /\\ /g' | xargs -0)

    # Add path to the script to force documentation rebuild on script updates
    SCRIPT_FULL_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/$(basename "${BASH_SOURCE[0]}")"
    echo -n "$SOURCES $DOCS $SCRIPT_FULL_PATH" >> "$DEPENDENCIES_FILE"
}

time main

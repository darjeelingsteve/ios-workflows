set -euo pipefail

echo "XCFramework build args: $@"

if [ $# -ne 6 ]; then
  echo ""
  echo "Error: Requires a project, scheme, and xcconfig path to be specified."
  echo ""
  echo "Usage: "
  echo "xcframework-build.sh -p Project.xcodeproj"
  echo "                     -s SchemeName"
  echo "                     -c XCConfig file path"
  echo ""
  exit 1
fi

while getopts p:s:c: option
do
  case "${option}"
  in
    p) PROJECT=${OPTARG};;
    s) SCHEME=${OPTARG};;
    c) XCCONFIG=${OPTARG};;
  esac
done

buildXCFramework() {
	# iOS Devices
	xcodebuild archive \
	    -project "$1.xcodeproj/" \
	    -scheme "$2" \
	    -archivePath "./xcframeworkarchives/$1/ios.xcarchive" \
	    -sdk iphoneos \
	    -xcconfig $3 \
	    | tee xcodebuild-raw.log \
	    | xcbeautify --renderer github-actions

	# iOS Simulator
	xcodebuild archive \
	    -project "$1.xcodeproj/" \
	    -scheme "$2" \
	    -archivePath "./xcframeworkarchives/$1/ios_sim.xcarchive" \
	    -sdk iphonesimulator \
	    -xcconfig $3 \
	    | tee xcodebuild-raw.log \
	    | xcbeautify --renderer github-actions

	# Create XCFramework
	xcodebuild -create-xcframework \
	    -framework "./xcframeworkarchives/$1/ios.xcarchive/Products/Library/Frameworks/$1.framework" \
	    -debug-symbols "$(pwd -P)/xcframeworkarchives/$1/ios.xcarchive/dSYMs/$1.framework.dSYM" \
	    -framework "./xcframeworkarchives/$1/ios_sim.xcarchive/Products/Library/Frameworks/$1.framework" \
	    -debug-symbols "$(pwd -P)/xcframeworkarchives/$1/ios_sim.xcarchive/dSYMs/$1.framework.dSYM" \
	    -output "./$1.xcframework" \
	    | tee xcodebuild-raw.log \
	    | xcbeautify --renderer github-actions
}

buildXCFramework $PROJECT $SCHEME $XCCONFIG

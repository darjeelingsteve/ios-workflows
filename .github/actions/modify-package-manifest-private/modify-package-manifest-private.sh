set -euo pipefail

echo "XCFramework build args: $@"

if [ $# -ne 6 ]; then
  echo ""
  echo "Error: Requires a path to the Package.swift manifest, zip URL, and checksum to be specified."
  echo ""
  echo "Usage: "
  echo "modify-package-manifest.sh -p path-to-Package.swift"
  echo "                           -u url-to-release-zip"
  echo "                           -c Zip checksum"
  echo ""
  exit 1
fi

while getopts p:u:c: option
do
  case "${option}"
  in
  	p) PACKAGE_MANIFEST=${OPTARG};;
    u) RELEASE_URL=${OPTARG};;
    c) CHECKSUM=${OPTARG};;
  esac
done

sed -i '' "s|\(let frameworkURL = \"\)[^\"]*\(\"\)|\1$RELEASE_URL\2|" $PACKAGE_MANIFEST
sed -i '' "s|\(let frameworkChecksum = \"\)[^\"]*\(\"\)|\1$CHECKSUM\2|" $PACKAGE_MANIFEST

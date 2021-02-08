i=0

PLIST=$1
while true ; do
	/usr/libexec/PlistBuddy -c "Print :__xctestrun_metadata__:CodeCoverageBuildableInfos:$i" $PLIST >/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		break
	fi

	PRODUCT_PATH=`/usr/libexec/PlistBuddy -c "Print :__xctestrun_metadata__:CodeCoverageBuildableInfos:$i:ProductPath" $PLIST`

	if [[ $PRODUCT_PATH != *"MapboxMaps.framework/MapboxMaps" ]]; then
		echo "skipping $PRODUCT_PATH"
	else 
		echo "Modifying $PRODUCT_PATH"

		/usr/libexec/PlistBuddy -c "Set :__xctestrun_metadata__:CodeCoverageBuildableInfos:$i:ProductPath __TESTROOT__/Debug-iphoneos/MapboxMaps.framework/MapboxMaps" $PLIST
		/usr/libexec/PlistBuddy -c "Set :__xctestrun_metadata__:CodeCoverageBuildableInfos:$i:SourceFilesCommonPathPrefix __TESTROOT__/Mapbox/MapboxMaps" $PLIST
	fi
	i=$(($i + 1))
done
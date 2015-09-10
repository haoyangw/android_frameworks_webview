#!/bin/bash

# Update prebuilt WebView library with com.google.android.webview apk
# Usage : ./extract.sh /path/to/com.google.android.webview.apk
#
# http://www.apkmirror.com/apk/google-inc/android-system-webview/

if [ $# > 1 ]; then
if [ "$2" ="x86" ]; then 
APK=webview-x86.apk
else
echo "Error! Unknown architecture given"
exit 1
fi
else
APK=webview.apk
fi

WEBVIEWVERSION=$(cat VERSION)
if ! apktool d -f -s "$1" 1>/dev/null; then
	echo "Failed to extract with apktool!"
	exit 1
fi
WEBVIEWDIR=$(\ls -d com.google.android.webview* || (echo "Input file is not a WebView apk!" ; exit 1))

NEWWEBVIEWVERSION=$(cat $WEBVIEWDIR/apktool.yml | grep versionName | awk '{print $2}')
if [[ $NEWWEBVIEWVERSION != $WEBVIEWVERSION ]]; then
	echo "Updating current WebView $WEBVIEWVERSION to $NEWWEBVIEWVERSION ..."
	echo $NEWWEBVIEWVERSION > VERSION
	rm -rf arm*
	mv $WEBVIEWDIR/lib/* .
	rm $APK
	rm -rf $WEBVIEWDIR
	7z x -otmp "$@" 1>/dev/null
	cd tmp
	rm -rf lib
	find . -name '*.png' -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1
	7z a -tzip -mx0 ../tmp.zip . 1>/dev/null
	cd ..
	rm -rf tmp
	zipalign -v 4 tmp.zip $APK 1>/dev/null
	rm tmp.zip
	rm -rf webview
else
	echo "Input WebView apk is the same version as before."
	echo "Not updating ..."
fi
rm -rf $WEBVIEWDIR

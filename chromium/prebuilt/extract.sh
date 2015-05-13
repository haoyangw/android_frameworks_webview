#!/bin/bash

# Update prebuilt WebView library with com.google.android.webview apk
# Usage : ./extract.sh /path/to/com.google.android.webview.apk
#
# http://www.apkmirror.com/apk/google-inc/android-system-webview/

WEBVIEWVERSION=$(cat VERSION)
if ! apktool d -f -s "$@" 1>/dev/null; then
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
	cp -f "$@" webview.apk
else
	echo "Input WebView apk is the same version as before."
	echo "Not updating ..."
fi
rm -rf $WEBVIEWDIR

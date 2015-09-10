#!/bin/bash

# Update prebuilt WebView library with com.google.android.webview apk
# Usage : ./extract.sh /path/to/com.google.android.webview.apk <x86>
#
# http://www.apkmirror.com/apk/google-inc/android-system-webview/

if [ $# -eq 0 ]; then
	echo "Error! No arguments given! Read syntax!"
	echo "Usage for x86 apk: ./extract.sh /path/to/com.google.android.webview.apk x86"
	echo "Usage for arm/arm64 apk: ./extract.sh /path/to/com.google.android.webview.apk"
	exit 1
fi

if [ "$2" = "x86" ]; then 
	echo "Updating webview for x86"
	APK=webview-x86.apk
elif [ "$2" = "" ]; then 
	echo "Updating webview for arm/arm64"
	APK=webview.apk
elif [ "$2" != "" ]; then 
	echo "Error! Unknown architecture given"
	exit 1
fi

WEBVIEWVERSION=$(cat VERSION)
if ! apktool d -f -s $1 1>/dev/null; then
	echo "Failed to extract with apktool!"
	exit 1
fi
WEBVIEWDIR=$(\ls -d com.google.android.webview*/ || (echo "Input file is not a WebView apk!" ; exit 1))

NEWWEBVIEWVERSION=$(cat $WEBVIEWDIR/apktool.yml | grep versionName | awk '{print $2}')
if [[ $NEWWEBVIEWVERSION != $WEBVIEWVERSION ]]; then
	echo "Updating current WebView $WEBVIEWVERSION to $NEWWEBVIEWVERSION ..."
	echo $NEWWEBVIEWVERSION > VERSION
	echo "(1/6) Removing files from old version(s)"
	rm -rf arm*
	mv $WEBVIEWDIR/lib/* .
	rm $APK
	rm -rf $WEBVIEWDIR
	echo "(1/6) Done!"
	echo "(2/6) Unzipping new webview apk to temporary location"
	7z x -otmp $1 1>/dev/null
	cd tmp
	rm -rf lib
	echo "(2/6) Done!"
	echo "(3/6) Shrinking pngs with pngquant"
	find . -name '*.png' -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1
	echo "(3/6) Done!"
	echo "(4/6) Compressing temporary directory back into an apk"
	7z a -tzip -mx0 ../tmp.zip . 1>/dev/null
	cd ..
	echo "(4/6) Done!"
	echo "(5/6) Removing temporary directory"
	rm -rf tmp
	echo "(5/6) Done!"
	echo "(6/6) Zipaligning new apk"
	zipalign -v 4 tmp.zip $APK 1>/dev/null
	rm tmp.zip
	rm -rf webview
	echo "Done!"
else
	echo "Input WebView apk is the same version as before."
	echo "Not updating ..."
fi
rm -rf $WEBVIEWDIR

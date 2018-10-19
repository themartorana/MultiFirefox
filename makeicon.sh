#!/usr/bin/env bash

# Make .icns file from mozilla's firefox svg icon asset (CC-BY-SA 3.0)
# Prereqs: curl, inkscape and pngcrush (brew cask install inkscape && brew install pngcrush) 
if [ ! -f firefox-logo.svg ]; then
  curl -L -O http://design.firefox.com/product-identity/firefox/firefox/firefox-logo.svg
fi
mkdir firefox.iconset
inkscape -z -e $(pwd)/firefox.iconset/icon_32x32.png -w 32 -h 32 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_32x32.png
inkscape -z -e $(pwd)/firefox.iconset/icon_32x32@2x.png -w 64 -h 64 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_32x32@2x.png
inkscape -z -e $(pwd)/firefox.iconset/icon_128x128.png -w 128 -h 128 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_128x128.png
inkscape -z -e $(pwd)/firefox.iconset/icon_128x128@2x.png -w 256 -h 256 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_128x128@2x.png
inkscape -z -e $(pwd)/firefox.iconset/icon_512x512.png -w 512 -h 512 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_512x512.png
inkscape -z -e $(pwd)/firefox.iconset/icon_512x512@2x.png -w 1024 -h 1024 $(pwd)/firefox-logo.svg
pngcrush -ow firefox.iconset/icon_512x512@2x.png
iconutil --convert icns firefox.iconset
rm -rf firefox.iconset

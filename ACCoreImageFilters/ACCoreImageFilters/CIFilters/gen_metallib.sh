#!/bin/sh


xcrun -sdk iphoneos metal -fcikernel ACImageMaskCIFilter.metal -c -o ACImageMaskCIFilter.air
xcrun -sdk iphoneos metallib -cikernel ACImageMaskCIFilter.air -o ACImageMaskCIFilter.metallib

xcrun -sdk iphoneos metal -fcikernel ACImageOpacityCIFilter.metal -c -o ACImageOpacityCIFilter.air
xcrun -sdk iphoneos metallib -cikernel ACImageOpacityCIFilter.air -o ACImageOpacityCIFilter.metallib

xcrun -sdk iphoneos metal -fcikernel ACImageClipCIFilter.metal -c -o ACImageClipCIFilter.air
xcrun -sdk iphoneos metallib -cikernel ACImageClipCIFilter.air -o ACImageClipCIFilter.metallib

rm *.air

echo "done"
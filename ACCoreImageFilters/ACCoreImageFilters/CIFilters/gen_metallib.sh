#!/bin/sh


xcrun -sdk iphoneos metal -fcikernel ACImageMaskCIFilter.metal -c -o ACImageMaskCIFilter.air
xcrun -sdk iphoneos metallib -cikernel ACImageMaskCIFilter.air -o ACImageMaskCIFilter.metallib

xcrun -sdk iphoneos metal -fcikernel ACImageOpacityFilter.metal -c -o ACImageOpacityFilter.air
xcrun -sdk iphoneos metallib -cikernel ACImageOpacityFilter.air -o ACImageOpacityFilter.metallib

rm *.air

echo "done"
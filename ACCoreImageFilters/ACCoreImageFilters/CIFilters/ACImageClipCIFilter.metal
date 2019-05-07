//
//  ACImageClipCIFilter.metal
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/7.
//  Copyright © 2019 albert. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 aCImageClip(sampler image,
                       sampler clipShapeImage) {
        float4 textureColor = image.sample(image.coord());
        float4 textureColor2 = clipShapeImage.sample(clipShapeImage.coord());

        float4 resTextureColor = textureColor;
        resTextureColor.a = textureColor.a * textureColor2.a;
        
        return resTextureColor;
    }
    
}}


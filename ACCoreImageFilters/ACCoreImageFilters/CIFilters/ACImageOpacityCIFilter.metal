//
//  ACImageOpacityCIFilter.metal
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/6.
//  Copyright © 2019 albert. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 acImageOpacity(sampler image,
                          float alpha) {
        float4 textureColor = image.sample(image.coord());
        textureColor.a = (alpha * textureColor.a);
        return textureColor;
    }
    
}}


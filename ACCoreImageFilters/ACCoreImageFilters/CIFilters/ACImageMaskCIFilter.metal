//
//  ACImageMaskCIFilter.metal
//  ACCoreImageFilters
//
//  Created by albert on 2019/4/30.
//  Copyright © 2019 albert. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {

    float4 acImageMask(sampler image,
                       float3 maskColor,
                       float needInvertedMask) {
        float4 textureColor = image.sample(image.coord());
        
        float alpha = textureColor.a;

        if (needInvertedMask > 0.0) {
            alpha = (1.0 - alpha);
        }
        return float4((maskColor.rgb * alpha), alpha);
    }
    
}}

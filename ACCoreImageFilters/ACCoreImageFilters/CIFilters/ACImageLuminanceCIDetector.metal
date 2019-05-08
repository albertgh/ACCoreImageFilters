//
//  ACImageLuminanceCIDetector.metal
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/8.
//  Copyright © 2019 albert. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 acImageLuminance(sampler image) {
        
        float3 luminanceWeighting = float3(0.2125, 0.7154, 0.0721);  // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
        
        float4 textureColor = image.sample(image.coord());

        float luminance = dot(textureColor.rgb, luminanceWeighting);
        
        return float4(float3(luminance), textureColor.a);
    }
    
}}


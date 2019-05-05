//
//  ACImageMaskCIFilter.h
//  ACCoreImageFilters
//
//  Created by albert on 2019/4/30.
//  Copyright © 2019 albert. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface ACImageMaskCIFilter : CIFilter

@property (nonatomic, strong) CIImage  *inputImage;

@property (nonatomic, strong) CIColor  *maskColor;

@property (nonatomic, assign) BOOL needInvertedMask;

@end


//
//  ACImageClipCIFilter.h
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/7.
//  Copyright © 2019 albert. All rights reserved.
//

#import <CoreImage/CoreImage.h>


@interface ACImageClipCIFilter : CIFilter

@property (nonatomic, strong) CIImage *inputImage;

@property (nonatomic, strong) CIImage *clipShapeImage;

@end


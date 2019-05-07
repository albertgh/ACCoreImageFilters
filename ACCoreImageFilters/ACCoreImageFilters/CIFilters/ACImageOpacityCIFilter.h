//
//  ACImageOpacityCIFilter.h
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/5.
//  Copyright © 2019 albert. All rights reserved.
//

#import <CoreImage/CoreImage.h>


@interface ACImageOpacityCIFilter : CIFilter

@property (nonatomic, strong) CIImage  *inputImage;

@property (nonatomic, assign) CGFloat alpha;

@end


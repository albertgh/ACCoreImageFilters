//
//  ACImageLuminanceCIDetector.h
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/7.
//  Copyright © 2019 albert. All rights reserved.
//

#import <CoreImage/CoreImage.h>


@interface ACImageLuminanceCIDetector : CIFilter

@property (nonatomic, strong) CIImage *inputImage;


- (CGFloat)imageLuminance;

@end


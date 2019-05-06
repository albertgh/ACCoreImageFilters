//
//  ACImageOpacityFilter.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/5.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACImageOpacityFilter.h"


@interface ACImageOpacityFilter()

@property (nonatomic, strong) CIKernel *customKernel;

@end


@implementation ACImageOpacityFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.customKernel == nil) {
            NSURL *kernelURL =
            [[NSBundle bundleForClass:[ACImageOpacityFilter class]]
             URLForResource:@"ACImageOpacityFilter"
             withExtension:@"metallib"];
            NSError *error;
            NSData *data = [NSData dataWithContentsOfURL:kernelURL];
            self.customKernel =
            [CIKernel kernelWithFunctionName:@"aCImageOpacity"
                        fromMetalLibraryData:data
                                       error:&error];
            
            if (@available(iOS 11.0, *)) {
            }
        }
    }
    return self;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CGRect dod = self.inputImage.extent;
    
    return [self.customKernel
            applyWithExtent:dod
            roiCallback:^CGRect(int index, CGRect destRect) {
                return destRect;
            }
            arguments:@[self.inputImage
                        , @(self.alpha)
                        ]
            ];
}


@end


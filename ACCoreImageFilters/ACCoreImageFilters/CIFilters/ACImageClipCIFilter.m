//
//  ACImageClipCIFilter.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/7.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACImageClipCIFilter.h"


@interface ACImageClipCIFilter()

@property (nonatomic, strong) CIKernel *customKernel;

@end


@implementation ACImageClipCIFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.customKernel == nil) {
            if (@available(iOS 11.0, *)) {
                NSURL *kernelURL =
                [[NSBundle bundleForClass:[ACImageClipCIFilter class]]
                 URLForResource:@"ACImageClipCIFilter"
                 withExtension:@"metallib"];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:kernelURL];
                self.customKernel =
                [CIKernel kernelWithFunctionName:@"aCImageClip"
                            fromMetalLibraryData:data
                                           error:&error];
                if (self.customKernel == nil) {
                    return nil;
                }
            } else {
                NSBundle *bundle = [NSBundle bundleForClass: [self class]];
                NSURL *kernelURL = [bundle URLForResource:@"ACImageClipCIFilter" withExtension:@"cikernel"];
                
                NSError *error;
                NSString *kernelCode =
                [NSString stringWithContentsOfURL:kernelURL
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
                if (kernelCode == nil) {
                    //NSLog(@"Error loading kernel code string in %@\n%@", NSStringFromSelector(_cmd), error.localizedDescription);
                    //abort();
                    return nil;
                }
                
                NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
                self.customKernel = [kernels objectAtIndex:0];
            }
        }
    }
    return self;
}

- (CIImage *)outputImage {
    if (!self.inputImage || !self.clipShapeImage) {
        return nil;
    }
    
    CGRect dod = self.inputImage.extent;
    
    return [self.customKernel
            applyWithExtent:dod
            roiCallback:^CGRect(int index, CGRect destRect) {
                if (index == 0) {
                    return self.inputImage.extent;
                } else {
                    return self.clipShapeImage.extent;
                }
            }
            arguments:@[self.inputImage
                        , self.clipShapeImage
                        ]
            ];
}


@end


//
//  ACImageOpacityCIFilter.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/5.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACImageOpacityCIFilter.h"


@interface ACImageOpacityCIFilter()

@property (nonatomic, strong) CIKernel *customKernel;

@end


@implementation ACImageOpacityCIFilter

- (instancetype)init {
    self = [super init];
    if (self) {        
        if (self.customKernel == nil) {
            if (@available(iOS 11.0, *)) {
                NSURL *kernelURL =
                [[NSBundle bundleForClass:[ACImageOpacityCIFilter class]]
                 URLForResource:@"ACImageOpacityCIFilter"
                 withExtension:@"metallib"];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:kernelURL];
                self.customKernel =
                [CIKernel kernelWithFunctionName:@"aCImageOpacity"
                            fromMetalLibraryData:data
                                           error:&error];
                if (self.customKernel == nil) {
                    return nil;
                }
            } else {
                NSBundle *bundle = [NSBundle bundleForClass: [self class]];
                NSURL *kernelURL = [bundle URLForResource:@"ACImageOpacityCIFilter" withExtension:@"cikernel"];
                
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


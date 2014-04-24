//
//  ALAsset+OrientationWithEdits.m
//  Curator
//
//  Created by Daniel Nordh on 24/04/2014.
//  Copyright (c) 2014 Daniel Nordh. All rights reserved.
//

#import "ALAsset+OrientationWithEdits.h"

@implementation ALAsset (OrientationWithEdits)

- (UIImage *)assetWithOrientationAndEdits:(ALAsset *)asset{
    
    ALAssetRepresentation *representation = [self defaultRepresentation];
    UIImage *assetImage;

    NSString *adjustmentXMP = [representation.metadata objectForKey:@"AdjustmentXMP"];
    NSData *adjustmentXMPData = [adjustmentXMP dataUsingEncoding:NSUTF8StringEncoding];
    
    CGRect extend = CGRectZero;
    extend.size = representation.dimensions;
    
    NSError *__autoreleasing error = nil;
    NSArray *filters = [CIFilter filterArrayFromSerializedXMP:adjustmentXMPData inputImageExtent:extend error:&error];
    
    if (filters) {
        // Apply filters, including crop
        CGImageRef fullResolutionImage = CGImageRetain(representation.fullResolutionImage);
        CIImage *image = [CIImage imageWithCGImage:fullResolutionImage];
        CIContext *context = [CIContext contextWithOptions:nil];
        
        for (CIFilter *filter in filters)
        {
            [filter setValue:image forKey:kCIInputImageKey];
            image = [filter outputImage];
        }
        
        CGImageRelease(fullResolutionImage);
        fullResolutionImage = [context createCGImage:image fromRect:image.extent];

        // Fix rotation
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
        
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        assetImage = [UIImage imageWithCGImage:fullResolutionImage scale:[[UIScreen mainScreen] scale] orientation:orientation];
        CGImageRelease(fullResolutionImage);
        
    } else {
        // Fix rotation for images without filters
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        assetImage = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:[[UIScreen mainScreen] scale] orientation:orientation];
    }
    return assetImage;
}

@end

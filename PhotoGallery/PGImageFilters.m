//
//  PGImageEffect.m
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGImageFilters.h"

@interface PGImageFilters ()
@property NSMutableArray *filters;
@property NSMutableArray *applyedFilters;
@end

@implementation PGImageFilters


-(id)init {
    if (!(self = [super init]))
        return nil;
    
    self.filters = [NSMutableArray array];
    self.applyedFilters = [NSMutableArray array];
    [self prepareFilters];
    return self;
}

-(NSUInteger) filtersCount {
    return [self.filters count];
}

-(void)prepareFilters {
    NSArray *nonUsableFilters = @[
    @"CIAdditionCompositing",
    @"CIBlendWithMask",
    @"CIColorMap",
    @"CICopyMachineTransition",
    @"CIDisintegrateWithMaskTransition",
    @"CIFlashTransition",
    @"CIMaximumCompositing",
    @"CIMinimumCompositing",
    @"CIModTransition",
    @"CIMultiplyCompositing",
    @"CISourceAtopCompositing",
    @"CISourceInCompositing",
    @"CISourceOutCompositing",
    @"CISourceOverCompositing",
    @"CISwipeTransition",
    @"CICheckerboardGenerator",
    @"CIConstantColorGenerator",
    @"CIGaussianGradient",
    @"CILinearGradient",
    @"CIRadialGradient",
    @"CIRandomGenerator",
    @"CISmoothLinearGradient",
    @"CIStarShineGenerator",
    @"CIStripesGenerator"
    ];
    
    NSArray *allNames = [CIFilter filterNamesInCategories:nil];
    NSMutableArray *filteredNames = [NSMutableArray array];

    for (NSString *filter in allNames)
        if (([nonUsableFilters indexOfObject:filter] == NSNotFound) && ([filteredNames indexOfObject:filter] == NSNotFound))
            if ([filter rangeOfString:@"Transition"].length <= 0)
                [filteredNames addObject:filter];
    
    NSLog(@"Available filters: %i\n%@", [filteredNames count], filteredNames);
    
    for (NSString *filter in filteredNames) {
            [self.filters addObject:[CIFilter filterWithName:filter]];
    }
}

-(CIImage *) processImage: (CIImage *) inputImage withFilter: (int) filterIndex {
    // pick a filter
    CIFilter *filter = [self.filters objectAtIndex:filterIndex];
    if (!filter) {
        return nil;
    }
    
    @try {
        // configure filter
        [filter setValue:inputImage forKey:@"inputImage"];
        
//        // execute filter
//        CGImageRef tempRef = [[CIContext contextWithOptions:nil]
//                              createCGImage:filter.outputImage
//                              fromRect:inputImage.extent];
//        
//        // convert output to certain image class
//        CIImage *outputImage = [CIImage imageWithCGImage:tempRef];
//        
//        // free temp image
//        CGImageRelease(tempRef);
        
        return filter.outputImage;//outputImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Unusable filter\n%@", [filter name]);
    }
    
    return nil;
}

+(CIImage *) makeCIImageFromUIImage: (UIImage *) sourceImage andFit: (CGSize) size {
    CGSize source = [sourceImage size];
    if (source.height <= 0 || source.width <= 0)
        return nil;
    
    CGFloat ratio = source.width / source.height;
    
    if (source.width > size.width) { // fit by width
        source.width = size.width;
        source.height = source.width / ratio;
    }
    if (source.height > size.height) { // fit by height
        source.height = size.height;
        source.width = source.height * ratio;
    }
    
    CGRect destRect = CGRectMake(0, 0, source.width,source.height);
    
    UIGraphicsBeginImageContext(source);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), destRect);
    [sourceImage drawInRect:destRect];
    
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [CIImage imageWithCGImage:[tempImage CGImage]];
}

-(void)startFilterGroup {
    [self.applyedFilters removeAllObjects];
}

-(void)pushFilter: (int) filterIndex {
    [self.applyedFilters addObject:[NSNumber numberWithInt:filterIndex]];
}

-(BOOL)popFilter {
    BOOL hasLast = [self.applyedFilters count];
    [self.applyedFilters removeLastObject];
    return hasLast;
}

-(BOOL)hasFiltersInGroup {
    return [self.applyedFilters count];
}

-(CIImage *)processImageWithFiltersGroup: (CIImage *) inputImage {
    for (NSNumber *index in self.applyedFilters) {
        inputImage = [self processImage:inputImage withFilter:[index integerValue]];
    }
    
    return inputImage;
}

@end

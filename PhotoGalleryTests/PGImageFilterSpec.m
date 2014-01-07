//
//  PGImageEffectsSpec.m
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "PGImageFilters.h"
#import "PGUtils.h"

SPEC_BEGIN(PGImageFiltersSpec)

describe(@"PGImageFilters class", ^{
        __block CIImage *inputImage;
        __block PGImageFilters *filtersManager;
        __block NSUInteger totalFilters;
        
        context(@"tests", ^{
            it(@"should succesfuly load test image", ^{
                UIImage *srcImage = [UIImage imageNamed:@"kenny.png"];
                CGImageRef ref = [srcImage CGImage];
                inputImage = [CIImage imageWithCGImage:ref];
                [inputImage shouldNotBeNil];
            });
        });

        it (@"should be properly instantiated with alloc init", ^{
            filtersManager = [[PGImageFilters alloc] init];
            [filtersManager shouldNotBeNil];
            
            [filtersManager prepareFilters];

            totalFilters = [filtersManager filtersCount];
            [[theValue(totalFilters) should] beGreaterThan:theValue(0)];
        });
        
        
        it(@"all effects must produce not nil result", ^{
            for (NSUInteger i = 0; i < totalFilters; i++) {
                CIImage *result = [filtersManager processImage:inputImage withFilter:i];
                [result shouldNotBeNil];
            }
        });
});

SPEC_END

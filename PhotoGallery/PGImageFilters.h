//
//  PGImageEffect.h
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreImage/CoreImage.h>

@interface PGImageFilters : NSObject

-(NSUInteger) filtersCount;
-(CIImage *) processImage: (CIImage *) inputImage withFilter: (int) filterIndex;

-(void)prepareFilters;
+(CIImage *) makeCIImageFromUIImage: (UIImage *) sourceImage andFit: (CGSize) size;

-(void)startFilterGroup;
-(BOOL)hasFiltersInGroup;
-(void)pushFilter: (int) filterIndex;
-(BOOL)popFilter;
-(CIImage *)processImageWithFiltersGroup: (CIImage *) inputImage;

@end

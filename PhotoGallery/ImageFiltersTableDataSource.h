//
//  PGImageEffectsTableDataSource.h
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGImageFilters.h"

@interface ImageFiltersTableDataSource : NSObject <UICollectionViewDataSource>

-(id)initWithFiltersManager: (PGImageFilters *)manager;

-(void)aquireData;
-(void)setupSourceImage: (CIImage *) image;

@end

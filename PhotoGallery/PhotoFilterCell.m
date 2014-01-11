//
//  PhotoEffectCell.m
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoFilterCell.h"

@implementation PhotoFilterCell

-(void)configureCellForFilter: (int)filterIndex inFilterManager: (PGImageFilters *)manager andSourceImage: (CIImage *) image
{
    [self queueImageLoad:image withBlock:^UIImage *(id image) {
        return [UIImage imageWithCIImage:
                [manager processImage:image withFilter:filterIndex]
                ];
    }];
}

@end

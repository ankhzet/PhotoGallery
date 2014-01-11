//
//  PhotoEffectCell.h
//  PhotoGallery
//
//  Collection cell that displays image filter preview.
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "PGImageFilters.h"
#import "DelayedLoadingCollectionCell.h"

@interface PhotoFilterCell : DelayedLoadingCollectionCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

-(void)configureCellForFilter: (int) filterIndex inFilterManager: (PGImageFilters *)manager andSourceImage: (CIImage *) image;

@end

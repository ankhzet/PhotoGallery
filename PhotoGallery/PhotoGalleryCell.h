//
//  PhotoGalleryCell.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Photo.h"
#import "DelayedLoadingCell.h"

@interface PhotoGalleryCell : DelayedLoadingCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

// Configure cell view with data from specified Photo *.
-(void)configureCellForPhoto:(Photo *)photo;

@end

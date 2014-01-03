//
//  PhotoGalleryCell.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoGalleryCell.h"

@implementation PhotoGalleryCell

-(void)configureCellForPhoto:(Photo *)photo {
    [self setImageIsLoading:YES];
    [self.titleLabel setText:[photo fileName]];
    [self.descriptionLabel setText:[photo metaDescription]];
    
    [photo getImageWithBlock:^(UIImage *image) {
        CGSize size = CGSizeMake(86, 68);
        [self.imageView setImage:[self resizeImage:image imageSize:size]]; // nice and handy thumbnail
//        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self setImageIsLoading:NO];
    }];
}

// Turn ON/OFF loading indicator. Not used yet.
-(void)setImageIsLoading:(BOOL)loading {
    [self.imageView setHidden:loading];
    if (loading)
        [self.imageView setImage:nil]; // memory saving
    
    [self.loadingIndicator setHidden:!loading];
    [self setNeedsLayout];
}

// make thumbnail for table cell (ImageView's ContentMode provides strange behavior when selecting cells =\).
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

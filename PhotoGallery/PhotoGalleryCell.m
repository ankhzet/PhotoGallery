//
//  PhotoGalleryCell.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoGalleryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoGalleryCell

-(void)configureCellForPhoto:(Photo *)photo {
	[self.titleLabel setText:[photo readableTimestamp]];
	[self.descriptionLabel setText:[photo metaDescription]];
	
	// prepare for loading image with loading indicator
	[self queueImageLoad:photo WithBlock:^UIImage *(id userData) {
		UIImage *image = [photo getImage]; // actual loading
																			 //        usleep(arc4random() % 1000000); // simulate network lag
		CGSize size = CGSizeMake(86, 68);
		return [self resizeImage:image imageSize:size];// return nice and handy thumbnail
	}];
	
	[self setNeedsLayout];
}

// make thumbnail for table cell (ImageView's ContentMode provides strange behavior when selecting cells =\).
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
	CGSize source = [image size];
	if (source.height <= 0 || source.width <= 0)
		return image;
	
	CGFloat ratio = source.width / source.height;
	
	if (source.width > size.width) { // fit by width
		source.width = size.width;
		source.height = source.width / ratio;
	}
	if (source.height > size.height) { // fit by height
		source.height = size.height;
		source.width = source.height * ratio;
	}
	
	CGRect destRect = CGRectMake(
															 (size.width - source.width) / 2.f,(size.height - source.height) / 2.f,
															 source.width,source.height);
	
	UIGraphicsBeginImageContext(size);
	
	CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor whiteColor] CGColor]);
	CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
	
	
	[image drawInRect:destRect];
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end

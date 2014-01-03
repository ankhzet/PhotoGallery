//
//  PhotoGalleryCell.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoGalleryCell.h"

@interface PhotoGalleryCell ()
@property (strong) NSOperationQueue *queue;
@end

@implementation PhotoGalleryCell

-(void)prepareForReuse {
    [self.titleLabel setText:@"reuse"];
    [self.descriptionLabel setText:@"reuse"];
    [self setImageIsLoading:YES];
}

-(void)configureCellForPhoto:(Photo *)photo {
    [self.titleLabel setText:[photo fileName]];
    [self.descriptionLabel setText:[photo metaDescription]];
    
    // prepare for loading image with loading indicator
    [self queueImageLoadForPhoto:photo];
}

-(void) queueImageLoadForPhoto: (Photo *) photo {
    // create new queue if this is first time
    if (!self.queue) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    } else
        // else cancell all operations on queue
        if (self.queue.operationCount)
            [self.queue cancelAllOperations];
    
    [self setImageIsLoading:YES]; // show loading indicator
    [self.queue addOperationWithBlock:^{
        __block UIImage *image = [photo getImage]; // actual loading
        usleep(arc4random() % 1000000); // simulate network lag
        CGSize size = CGSizeMake(86, 68);
        image = [self resizeImage:image imageSize:size];// nice and handy thumbnail
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.imageView setImage: image]; // setup image
            [self setImageIsLoading:NO]; // hide loading indicator
        }];
        
    }];

}

// Turn ON/OFF loading indicator. Not used yet.
-(void)setImageIsLoading:(BOOL)loading {
    [self.imageView setHidden:loading];
    [self.loadingIndicator setHidden:!loading];
    if (loading) {
        [self.imageView setImage:nil]; // memory saving
        [self.loadingIndicator startAnimating];
    }
    
    [self setNeedsLayout]; // simple redisplay won't work properly
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

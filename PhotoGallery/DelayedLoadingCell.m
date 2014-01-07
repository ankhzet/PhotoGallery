//
//  DelayedLoadingCell.m
//  PhotoGallery
//
//  Created by Ankh on 07.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "DelayedLoadingCell.h"
#import <QuartzCore/QuartzCore.h>


@interface DelayedLoadingCell ()
@property (strong) NSOperationQueue *queue;
@end

@implementation DelayedLoadingCell

-(void) queueImageLoad:(id) userData WithBlock: (PreparePreviewBlock) block {
    // create new queue if this is first time
    if (!self.queue) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;

        // and configure image layer 
        CALayer *layer = [self.imageView layer];
        layer.cornerRadius = 4.0;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.borderWidth = 1.0;
    } else
        // else cancell all operations on queue
        if (self.queue.operationCount)
            [self.queue cancelAllOperations];
    
    [self setImageIsLoading:YES]; // show loading indicator
    [self.queue addOperationWithBlock:^{
        __block UIImage *image = block(userData);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.imageView setImage: image]; // setup image
            [self setImageIsLoading:NO]; // hide loading indicator
        }];
        
    }];
}

// Turn ON/OFF loading indicator.
-(void)setImageIsLoading:(BOOL)loading {
    [self.imageView setHidden:loading];
    [self.loadingIndicator setHidden:!loading];
    if (loading) {
        [self.imageView setImage:nil]; // memory saving
        [self.loadingIndicator startAnimating];
    }
    
    [self setNeedsLayout]; // simple redisplay won't work properly
}

@end

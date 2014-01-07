//
//  DelayedLoadingCollection.m
//  PhotoGallery
//
//  Created by Ankh on 07.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "DelayedLoadingCollectionCell.h"
#import <QuartzCore/QuartzCore.h>

@interface DelayedLoadingCollectionCell ()
@property (strong) NSOperationQueue *queue;
@property (atomic) NSUInteger queueID;
@end

@implementation DelayedLoadingCollectionCell

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
    } else {
        // else cancell all operations on queue
        [self.queue cancelAllOperations];
    }
    
    [self setImageIsLoading:YES]; // show loading indicator
    [self.queue addOperationWithBlock:^{
        __block UIImage *image = block(userData);
        self.queueID++;
        __block NSUInteger queuedID = self.queueID;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.queueID != queuedID)
                return;
            
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

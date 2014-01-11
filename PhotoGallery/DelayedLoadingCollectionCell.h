//
//  DelayedLoadingCollection.h
//  PhotoGallery
//
//  Created by Ankh on 07.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIImage * (^PreparePreviewBlock) (id userData);

@interface DelayedLoadingCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

-(void) queueImageLoad:(id) userData withBlock: (PreparePreviewBlock) block;

-(void)setImageIsLoading:(BOOL)loading;

// Highlite (when cell selected) image by change it's border color.
-(void) highliteImage: (UIColor *) highlightColor;

@end

//
//  DelayedLoadingCollection.h
//  PhotoGallery
//
//  Collection cell with imageview element and image preloading functionality.
//  Displays activity indicator while underlying image is loading. 
//
//  Created by Ankh on 07.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIImage * (^PreparePreviewBlock) (id userData);

@interface DelayedLoadingCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

// Method executes given block in separate thread (operation queue), and after completion
// displays resulting image in imageview. While block executing, activity indicator will be shown.
-(void) queueImageLoad:(id) userData withBlock: (PreparePreviewBlock) block;

// Show/hide loading indicator
-(void) setImageIsLoading:(BOOL)loading;

// Highlite (when cell selected) image by change it's border color.
-(void) highliteImage: (UIColor *) highlightColor;

@end

//
//  PhotoFiltersViewController.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFiltersTableDataSource.h"

@interface PhotoFiltersViewController : UIViewController <UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *filtersColectionView;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)actionUndoFilter:(id)sender;
- (IBAction)actionApplyFilter:(id)sender;

- (IBAction)actionSave:(id)sender;

@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic, strong) ImageFiltersTableDataSource *dataSource;

-(void) setupBeforeShow:(UIImage *)image;
@end

//
//  PhotoDetailViewController.h
//  PhotoGallery
//
//  Created by Ankh on 02.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol PhotoDetailsControllerDelegate <NSObject>

-(void)didDoneWithDetails:(id)sender andReload: (BOOL) reload;

@end

@interface PhotoDetailViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
- (IBAction)actionSave:(id)sender;
- (IBAction)actionDelete:(id)sender;

@property (nonatomic, weak) id<PhotoDetailsControllerDelegate> delegate;
@property (nonatomic, weak) Photo *photo;

// interface method for parent view fontroller to setup this view with delegate & photo data
-(void)setupBeforeShow:(id<PhotoDetailsControllerDelegate>)delegate withPhoto: (Photo *) photo;
@end

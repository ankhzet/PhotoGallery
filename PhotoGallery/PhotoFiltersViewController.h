//
//  PhotoFiltersViewController.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFiltersViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)actionSave:(id)sender;
@end

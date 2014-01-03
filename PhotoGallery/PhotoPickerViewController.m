//
//  PhotoPickerViewController.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoPickerViewController.h"

@interface PhotoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation PhotoPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.picker = [[UIImagePickerController alloc] initWithRootViewController:self];
//    self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    self.picker.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ImagePicker delegate.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
}

@end

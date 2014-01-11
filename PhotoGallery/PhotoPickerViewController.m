//
//  PhotoPickerViewController.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PhotoFiltersViewController.h"

@interface PhotoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic) BOOL showPicker;
@end

@implementation PhotoPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showPicker = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.showPicker)
        [self showPhotoPicker:self.imageView.frame];
}

// ImagePicker delegate.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageView setImage:self.pickedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"showFilters" sender:self];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.showPicker = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }];
}

// setup Filters-view before displaying it
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFilters"]) {
        PhotoFiltersViewController *dvc = [segue destinationViewController];
        [dvc setupBeforeShow:self.pickedImage];
    }
}

-(void) showPhotoPicker: (CGRect) popoverFrame {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [picker setSourceType:sourceType];
    
    // Set up the other imagePicker properties
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

@end

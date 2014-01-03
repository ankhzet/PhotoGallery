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
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIImage *pickedImage;
@end

@implementation PhotoPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pickedImage = nil;
    
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
    self.pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [[self navigationController] performSegueWithIdentifier:@"showFilters" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFilters"]) {
        PhotoFiltersViewController *dvc = [segue destinationViewController];
        [dvc setupBeforeShow:self.pickedImage];
    }
}

@end

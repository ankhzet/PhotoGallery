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
    
    NSString *images[] = {@"strange.png", @"and-cat.png", @"BiOmega.jpg", @"dark-air.jpg", @"wallmen.jpg"};
    
    self.pickedImage = [UIImage imageNamed:images[arc4random() % 5]];
    
    [self.imageView setImage:self.pickedImage];
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

// setup Filters-view before displaying it
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFilters"]) {
        PhotoFiltersViewController *dvc = [segue destinationViewController];
        [dvc setupBeforeShow:self.pickedImage];
    }
}

@end

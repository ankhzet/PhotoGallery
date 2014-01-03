//
//  PhotoFiltersViewController.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoFiltersViewController.h"
#import "Photo.h"

#import "PGUtils.h"

#import "PhotoGalleryViewController.h"

@interface PhotoFiltersViewController ()

@end

@implementation PhotoFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupBeforeShow:(UIImage *)image {
    [self.imageView setImage:image];
}

// User pressed "Done" toolbar button. Save image and metadata to database and pop controllers stack to master view controller.
- (IBAction)actionSave:(id)sender {
    [Photo newPhotoFromImage:[self.imageView image]];
    
    if (![PGUtils saveContext])
        return;
    
    PhotoGalleryViewController *masterController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    [masterController reloadTable];
    [self.navigationController popToViewController:masterController animated:YES];
}

@end

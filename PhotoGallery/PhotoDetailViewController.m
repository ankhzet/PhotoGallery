//
//  PhotoDetailViewController.m
//  PhotoGallery
//
//  Created by Ankh on 02.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PGDataProxyContainer.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup image & description controls
    UIImage *image = [self.photo getImage];
    [self.imageView setImage:image];
    [self.imageView setNeedsDisplay];
    [self.descriptionText setText:[self.photo metaDescription]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // try to survive =D
    [self.imageView setImage:nil];
}

#pragma mark - Main code


// setup method
-(void)setupBeforeShow:(id<PhotoDetailsControllerDelegate>)delegate withPhoto: (Photo *) photo {
    self.delegate = delegate;
    self.photo = photo;
}

// After user press "Done" button we must save changes to db and show master view.
- (IBAction)actionSave:(id)sender {
    [self.photo setMetaDescription:[self.descriptionText text]];
    if (![PGDataProxyContainer saveContext]) {
        return;
    }
    
    [self.delegate didDoneWithDetails:self andReload:YES];
}

// On button "Trash" pressed - delete photo and return to master view
- (IBAction)actionDelete:(id)sender {
    if (![self.photo deletePhoto])
        return;
    
    [self.delegate didDoneWithDetails:self andReload:YES];
}

@end

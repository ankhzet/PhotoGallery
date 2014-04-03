//
//  PhotoDetailViewController.m
//  PhotoGallery
//
//  Created by Ankh on 02.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PGDataProxyContainer.h"

#import <ShareKit/ShareKit.h>

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

- (void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self.descriptionBackground setFrame:CGRectInset(self.descriptionText.frame, 0, -2)];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.descriptionBackground setFrame:CGRectInset(self.descriptionText.frame, 0, -2)];
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

// When user presses "Share" button on toolbar - show ShareKit action sheet
- (IBAction)actionShare:(id)sender {
	SHKItem *item = [SHKItem image:[self.photo getImage] title:[self.photo metaDescription]];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromToolbar:self.toolbar];
}

@end

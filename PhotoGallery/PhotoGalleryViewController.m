//
//  PhotoGalleryViewController.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoGalleryViewController.h"

#import "PreferencesViewController.h"
#import "PhotoDetailViewController.h"
#import "PhotoFiltersViewController.h"

#import "PGDataProxyContainer.h"
#import "PGSynkEnabledStorage.h"

@interface PhotoGalleryViewController () <PreferencessControllerDelegate, PhotoDetailsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage *pickedImage;

- (IBAction)actionTakephoto:(id)sender;
@end

@implementation PhotoGalleryViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
  
	self.dataSource = [[PhotosTableDataSource alloc] init];
	
	[self.tableView setDataSource:self.dataSource];
	[self.tableView setDelegate:self.dataSource];
	
	// when using ICloudEnabledStorage, must manualy subscribe for data updates notification,
	// because ICloudEnabledStorage initializes storage in separate thread, and after first
	// aquire of persistent storage data isn't actually loaded yet
//	id proxy = [[PGDataProxyContainer getInstance] dataProxy];
//	[proxy subscribeForUpdateNotifications:self selector:@selector(onCoreDataUpdate:)];

	// notification may be sended already
	[self reloadTable];
}

-(void)viewDidUnload {
	[super viewDidUnload];
	
//	// don't forget to unsubscribe and remove circular referencing...
//	id proxy = [[PGDataProxyContainer getInstance] dataProxy];
//	[proxy unSubscribeFromUpdateNotifications:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

// notification about coredata state update (on first load or iCloud import)
- (void)onCoreDataUpdate:(NSNotification*)notification {
	[self reloadTable];
}

-(void)reloadTable {
	[self.dataSource aquireData];
	[self.tableView reloadData];
}

#pragma mark - Photo picker

- (IBAction)actionTakephoto:(id)sender {
	[self showPhotoPicker:self.view.frame];
}

// ImagePicker delegate.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	self.pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	[self dismissViewControllerAnimated:YES completion:nil];
	[self performSegueWithIdentifier:@"showFilters" sender:self];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:^{
		//		[[self navigationController] popToRootViewControllerAnimated:YES];
	}];
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

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier]isEqualToString:@"showPreferences"]) {
		UINavigationController *dvc = [segue destinationViewController];
		PreferencesViewController *pvc = [dvc viewControllers][0];
		pvc.delegate = self;
	}
	
	if ([[segue identifier]isEqualToString:@"showPhotoDetails"]) {
		PhotoDetailViewController *dvc = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		[dvc setupBeforeShow:self withPhoto:[self.dataSource.photos objectAtIndex:indexPath.row]];
	}
	
	if ([[segue identifier] isEqualToString:@"showFilters"]) {
		PhotoFiltersViewController *dvc = [segue destinationViewController];
		[dvc setupBeforeShow:self.pickedImage];
	}
}

#pragma mark - Delegate callbacks

-(void)didDoneWithPreferences:(id)sender {
	[sender dismissViewControllerAnimated:YES completion:NULL];
	((PreferencesViewController *)sender).delegate = NULL;
}

-(void)didDoneWithDetails:(id)sender andReload: (BOOL) reload {
	[self.navigationController popToViewController:self animated:YES];
	((PhotoDetailViewController *)sender).delegate = NULL;
	[self reloadTable];
}

@end

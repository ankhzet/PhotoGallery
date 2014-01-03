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

@interface PhotoGalleryViewController () <PreferencessControllerDelegate, PhotoDetailsControllerDelegate>

@end

@implementation PhotoGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = [[PhotosTableDataSource alloc] init];
    
    [self.tableView setDataSource:self.dataSource];
    [self.tableView setDelegate:self.dataSource];
    
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)reloadTable {
    [self.dataSource aquireData];
    [self.tableView reloadData];
}

#pragma mark Segues

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
}

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

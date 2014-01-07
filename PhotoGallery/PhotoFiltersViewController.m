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
#import "PGImageFilters.h"

@interface PhotoFiltersViewController ()
@property (nonatomic, strong) PGImageFilters *filtersManager;
@property (nonatomic, strong) NSIndexPath *selectedFilter;
@property (nonatomic, strong) CIImage *minifiedImage;
@property (atomic, strong) NSOperationQueue *previewGenerationQueue;
@end

@implementation PhotoFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.previewGenerationQueue) {
        self.previewGenerationQueue = [[NSOperationQueue alloc] init];
        self.previewGenerationQueue.maxConcurrentOperationCount = 1;
    }
    
    // prepare minified image for filter preview
    CGSize viewSize = CGSizeMake(280, 303);
    CGSize imageSize = [self.pickedImage size];
    CGSize minifiedSize = CGSizeMake(viewSize.width, viewSize.height);
    if ((minifiedSize.width > imageSize.width) || (minifiedSize.height > imageSize.height)) {
        minifiedSize = imageSize;
    }
    self.minifiedImage = [PGImageFilters makeCIImageFromUIImage:self.pickedImage andFit:minifiedSize];

    // setup filters manager
    self.filtersManager = [[PGImageFilters alloc]init];
    self.dataSource = [[ImageFiltersTableDataSource alloc] initWithFiltersManager:self.filtersManager];

    [self.filtersColectionView setDataSource:self.dataSource];
    [self.filtersColectionView setDelegate:self];
    
    [self.filtersManager startFilterGroup];
    [self applyFilters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupBeforeShow:(UIImage *)image {
    self.pickedImage = image;
}

-(void)reloadData {
    [self.dataSource aquireData];
    [self.filtersColectionView reloadData];
}

// apply all selected filters to source image (it's minified copy) and update filters collection table
-(void) applyFilters {
    [self.loadingIndicator setHidden:NO];
    [self.loadingIndicator startAnimating];
    
    [self.undoButton setEnabled:[self.filtersManager hasFiltersInGroup]];
    [self.applyButton setEnabled:NO];
    
    [self.previewGenerationQueue addOperationWithBlock:^{
        // process minified image with filters
        CIImage *processedImage = [self.filtersManager processImageWithFiltersGroup:self.minifiedImage];
        UIImage *preview = [UIImage imageWithCIImage:processedImage];
        
        // supply filters collection data source with sample image
        CGSize sourceSize = [processedImage extent].size;
        CGSize previewSampleImageSize = CGSizeMake(sourceSize.width / 4, sourceSize.height / 4);
        CIImage *sampleImage = [PGImageFilters makeCIImageFromUIImage:preview andFit:previewSampleImageSize];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // show preview
            [self.imageView setImage:preview];
            [self.imageView setNeedsLayout];
            [self.loadingIndicator setHidden:YES];
            
            [self.dataSource setupSourceImage: sampleImage];
            
            // update collection table
            [self reloadData];
        }];
    }];
}

#pragma mark - IBActions

// User pressed "Done" toolbar button. Save image and metadata to database and pop controllers stack to master view controller.
- (IBAction)actionUndoFilter:(id)sender {
    if([self.filtersManager popFilter])
        [self applyFilters];
}

- (IBAction)actionApplyFilter:(id)sender {
    [self.filtersManager pushFilter:[self.selectedFilter row]];
    [self applyFilters];
}


// save new photo to db with all selected filters applyed
- (IBAction)actionSave:(id)sender {
    // apply filters
    CIImage *source = [CIImage imageWithCGImage:[self.pickedImage CGImage]];
    CIImage *processed = [self.filtersManager processImageWithFiltersGroup:source];
    CGImageRef tempRef = [[CIContext contextWithOptions:nil]
                          createCGImage:processed
                          fromRect:processed.extent];
    
    // new entity from image
    [Photo newPhotoFromImage:[UIImage imageWithCGImage:tempRef]];
    // free temp image
    CGImageRelease(tempRef);
    
    // try to save changes
    if (![PGUtils saveContext])
        return;
    
    // dirty game =(
    PhotoGalleryViewController *masterController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    [masterController reloadTable];
    [self.navigationController popToViewController:masterController animated:YES];
}

#pragma mark - Collection view delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilter = indexPath;
    [self.applyButton setEnabled:indexPath != nil];
}

@end

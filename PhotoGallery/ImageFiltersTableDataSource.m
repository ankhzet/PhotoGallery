//
//  PGImageEffectsTableDataSource.m
//  PhotoGallery
//
//  Created by Ankh on 06.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "ImageFiltersTableDataSource.h"
#import "PhotoFilterCell.h"
#import "PGImageFilters.h"

@interface ImageFiltersTableDataSource ()
@property (nonatomic, strong) PGImageFilters *filtersManager;
@property (nonatomic, strong) CIImage *sourceImage;

@end

@implementation ImageFiltersTableDataSource

-(id)initWithFiltersManager: (PGImageFilters *) manager {
	if (!(self = [super init]))
		return nil;
	
	self.filtersManager = manager;
	
	return self;
}

-(void)aquireData {
	[self.filtersManager prepareFilters];
}

-(void)setupSourceImage:(CIImage *)image {
	self.sourceImage = image;
}

#pragma mark - Data source delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.filtersManager filtersCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"PhotoFilterCell";
	
	PhotoFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	
	[cell configureCellForFilter:[indexPath row] inFilterManager:self.filtersManager andSourceImage:self.sourceImage];
	return cell;
}

@end

//
//  PhotoGalleryTests.m
//  PhotoGalleryTests
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PhotoGalleryTests.h"

#import "Photo.h"
#import "PGUtils.h"
#import "PhotoGalleryCell.h"

@interface PhotoGalleryTests ()
@property (nonatomic, strong) PhotoGalleryCell * photoCell;

@end

@implementation PhotoGalleryTests



NSManagedObjectContext *context;

- (void)setUp
{
    [super setUp];
    
    context = [[PGUtils getInstance]managedObjectContext];
    
    STAssertNotNil(context, @"ManagedObjectContext should not be nil");
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPhotoEntity
{
    UIImage *image = [UIImage imageNamed:@"wallmen.jpg"];
    STAssertNotNil(image, @"Test image should not be nil");
    
    Photo *entity = [Photo newPhotoFromImage:image];
    STAssertNotNil(entity, @"Entity should not be nil");

    
    @try {
        STAssertNotNil([entity timestamp], @"Entity timestamp should not be nil");
        
        STAssertNotNil([entity fileName], @"Entity filename should not be nil");
        
        STAssertNotNil([entity getImage], @"Entity should return not nil image");
        
        NSLog(@"Entity:\n%@", entity);
    }
    @finally {
        [context deleteObject:entity];
    }
    
}

- (void) testPhotoGalleryCell {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryCell" owner:self options:nil];
    
    PhotoGalleryCell *cell = nibs[0];
    
    STAssertNotNil(cell, @"Gallery cell from PhotoGalleryCell.xib should not be nil");
    
    STAssertTrue([cell isMemberOfClass:[PhotoGalleryCell class]], @"Gallery cell from PhotoGalleryCell.xib should be instance of PhotoGalleryCell");
    
    STAssertNotNil(cell.titleLabel, @"Cell title label sholdn't be nil");
    STAssertNotNil(cell.descriptionLabel, @"Cell description label sholdn't be nil");
    STAssertNotNil(cell.imageView, @"Cell image view sholdn't be nil");
    STAssertNotNil(cell.loadingIndicator, @"Cell loading indicator sholdn't be nil");
}

@end

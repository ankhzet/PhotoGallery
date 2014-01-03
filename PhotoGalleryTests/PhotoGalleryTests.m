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
        
        [entity getImageWithBlock:^(UIImage *image) {
            STAssertNotNil([entity getImage], @"Image, retrived with block should not be nil");
        }];
        
        NSLog(@"Entity:\n%@", entity);
    }
    @finally {
        [context deleteObject:entity];
    }
    
}

@end

//
//  Photo.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Photo.h"
#import "PGUtils.h"

@implementation Photo

@dynamic fileName;
@dynamic timestamp;
@dynamic metaDescription;
@dynamic metaGPSLocation;

NSString *fileNamePattern = @"photo-%@.jpg";
NSString *fileDateTimePattern = @"dd-mm-yy_hh-ss";
CGFloat compressionForJPEG = 0.85;

+(Photo *) newPhotoFromImage: (UIImage *) image {
    NSDate *creationTime = [NSDate date];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:fileDateTimePattern];
    
    // resulting filename
    NSString *fileName = [NSString stringWithFormat:fileNamePattern, [df stringFromDate:creationTime]];
    
    // saving image data to file
    NSData *imageData = UIImageJPEGRepresentation(image, compressionForJPEG);
    if (![imageData writeToURL:[self makeAbsolutePathForPhotoFile:fileName] atomically:YES])
        return nil;
    
    // instantiating database entity
    Photo *instance = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[[PGUtils getInstance] managedObjectContext]];
    
    // initialize entity
    [instance setTimestamp:creationTime];
    [instance setFileName:fileName];
    
    // try to pick geolocation
    [PGUtils aquireGeoLocationWithBlock:^(CLLocation *location) {
        NSString *locationString = [NSString stringWithFormat:@"%f %f", location.coordinate.latitude, location.coordinate.longitude];
        [instance setMetaGPSLocation:locationString];
    }];
    
    return instance;
}

-(BOOL) deletePhoto {
    NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:[self fileName]];
    
    // first try to delete image file
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
        NSLog(@"Error while deleting \"%@\": %@", [self fileName], [error localizedDescription]);
        return NO;
    }
    
    // all is OK, delete from database
    NSManagedObjectContext *context = [[PGUtils getInstance] managedObjectContext];
    [context deleteObject:self];
    
    // finally, flush database to storage
    return [PGUtils saveContext];
}

+(NSURL *) makeAbsolutePathForPhotoFile:(NSString *)fileName {
    return [[PGUtils applicationDocumentsDirectory] URLByAppendingPathComponent:fileName];
}

-(UIImage *) getImage {
    NSString *filePath = [[Photo makeAbsolutePathForPhotoFile:[self fileName]] path];
    return [UIImage imageWithContentsOfFile:filePath];
}

-(void) getImageWithBlock: (PhotoImageLoaderCompletionBlock) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block UIImage *image = [self getImage];
        usleep(arc4random() % 5000000);
        dispatch_async(dispatch_get_main_queue(), ^{
            block(image);
        });
    });
}

@end

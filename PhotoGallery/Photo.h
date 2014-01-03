//
//  Photo.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^PhotoImageLoaderCompletionBlock)(UIImage *image);

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * metaDescription;
@property (nonatomic, retain) NSString * metaGPSLocation;


// Create new foto entity in database with current timestamp and filename as "dd-mm-yyy_hh-ss.jpg".
// Image data will be written to file in application documents directory.
+(Photo *) newPhotoFromImage: (UIImage *) image;
// Delete photo. First image file will be deleted, then photo entity will be removed from database. 
-(BOOL) deletePhoto;

// Returns absolute path for photo file with specified filename.
+(NSURL *) makeAbsolutePathForPhotoFile:(NSString *)fileName;

// Loads image data from file.
-(UIImage *) getImage;

// readable timestaml to display in table view
-(NSString *) readableTimestamp;

@end

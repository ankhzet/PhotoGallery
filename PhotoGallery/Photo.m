//
//  Photo.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Photo.h"
#import "PGDataProxyContainer.h"
#import "PGUtils.h"

@implementation Photo

@dynamic fileName;
@dynamic timestamp;
@dynamic metaDescription;
@dynamic metaGPSLocation;

NSString *fileNamePattern = @"photo-%@.jpg";
NSString *fileDateTimePattern = @"dd-MM-yy_HH-mm-ss";
NSString *readableDateTimePattern = @"dd/MM/yyyy HH:mm";
CGFloat compressionForJPEG = 0.75;

+(Photo *) newPhotoFromImage: (UIImage *) image {
	NSDate *creationTime = [NSDate date];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:fileDateTimePattern];
	
	// resulting filename
	// may be problems with GMT & timezones =(
	NSString *fileName = [NSString stringWithFormat:fileNamePattern, [df stringFromDate:creationTime]];
	
	// saving image data to file
	NSData *imageData = UIImageJPEGRepresentation(image, compressionForJPEG);
	if (![imageData writeToURL:[self makeAbsolutePathForPhotoFile:fileName] atomically:YES])
		return nil;
	
	// instantiating database entity
	Photo *instance = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[[PGDataProxyContainer getInstance] managedObjectContext]];
	
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


// check, if this entity was deleted, then delete referenced image file (on iCloud also), if needed.
// if file was linked with iCloud copy, it will be removed from iCloud storage to (i guess...).
-(void)didSave {
	[super didSave];
	
	if ([self isDeleted]) {
		[self deleteImage]; // try to delete image, if it still exists
	}
}

-(BOOL) deleteImage {
	NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:[self fileName]];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
		return YES; // file already doesn't exists
	
	NSError *error = nil;
	if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
		NSLog(@"Error while deleting \"%@\": %@", [self fileName], [error localizedDescription]);
		return NO;
	}
	
	return YES;
}

-(BOOL) deletePhoto {
	// first try to delete image file
	// later, [moc saveContext] will trigger file deletion again, but file will be already deleted (no exceptions will be thrown).
	if (![self deleteImage]) {
		return NO; // oops, deletion failed oO
	}
	
	// all is OK, delete from database
	NSManagedObjectContext *context = [[PGDataProxyContainer getInstance] managedObjectContext];
	[context deleteObject:self];
	
	// finally, flush database to storage
	return [PGDataProxyContainer saveContext];
}

+(NSURL *) makeAbsolutePathForPhotoFile:(NSString *)fileName {
	return [[PGUtils applicationDocumentsDirectory] URLByAppendingPathComponent:fileName];
}

-(UIImage *) getImage {
	NSString *filePath = [[Photo makeAbsolutePathForPhotoFile:[self fileName]] path];
	return [UIImage imageWithContentsOfFile:filePath];
}

-(NSString *) readableTimestamp {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:readableDateTimePattern];
	
	return [df stringFromDate:[self timestamp]];
}

@end

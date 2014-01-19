//
//  Utils.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGUtils.h"

// custom location manager to handle block-processing
@interface PGCLLocationManager : CLLocationManager <CLLocationManagerDelegate>
{
	GeoLocationReceiverBlock onUpdateBlock;
}
-(id)initWithCompletionBlock:(GeoLocationReceiverBlock) block;
@end

// private interface to manage active loc-manager instances
@interface PGUtils()
@property (nonatomic, strong) NSMutableArray *locationManagers;
@end


@implementation PGUtils

// main init method
-(id) init {
	if (!(self = [super init]))
		return nil;
	
	_locationManagers = [NSMutableArray array];
	
	return self;
}

#pragma mark - Common utils

// Returns the URL to the application's Documents directory.
+(NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Aquire GeoLocation. Location will be delivered in supplied code-block.
+(void)aquireGeoLocationWithBlock: (GeoLocationReceiverBlock)block {
	// init new manager
	PGCLLocationManager *locationManager = [[PGCLLocationManager alloc] initWithCompletionBlock:block];
	
	[locationManager startUpdatingLocation];
	
	// save instance of manager to protect it from gc and/or manage it later
	[[[self getInstance] locationManagers] addObject:locationManager];
}

// singletone getter
+(id) getInstance {
	static PGUtils *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[PGUtils alloc] init];
	});
	
	return instance;
}


#pragma mark - Private methods

// Private method. Remove manager, that was instantiated earlier.
+(void)removeGLManager:(id)manager{
	[[[self getInstance] locationManagers] removeObject:manager];
}

@end

#pragma mark - PGCLLocationManager implementation

@implementation PGCLLocationManager

// setup manager
-(id)initWithCompletionBlock:(GeoLocationReceiverBlock) block {
	if (!(self = [super init]))
		return nil;
	
	[self setDistanceFilter:kCLDistanceFilterNone];
	[self setDesiredAccuracy:kCLLocationAccuracyBest];
	[self setDelegate:self];
	self->onUpdateBlock = block;
	
	return self;
}

// delegate callback implementation. Method calls supplied on-update block and releases CLLocationManager object, which was instantiated previously.
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
	PGCLLocationManager *pgManager = (PGCLLocationManager *)manager;
	
	@try { // be sure to cleanup even after in-block exceptions - no need to lock system resources
		pgManager->onUpdateBlock(location);
	}
	@finally {
		[pgManager stopUpdatingLocation];
		[pgManager setDelegate:nil];
		[PGUtils removeGLManager:pgManager];
	}
}

@end


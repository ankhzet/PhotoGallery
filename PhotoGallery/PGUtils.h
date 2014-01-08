//
//  Utils.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

// block for geoloc aquire completion handling
typedef void (^GeoLocationReceiverBlock)(CLLocation *location);

// util functions
@interface PGUtils : NSObject

// singletone =\.
+(id) getInstance;
// aquire geoloc with completion block
+(void)aquireGeoLocationWithBlock: (GeoLocationReceiverBlock)block;

// applications document directory
+(NSURL *)applicationDocumentsDirectory;

@end

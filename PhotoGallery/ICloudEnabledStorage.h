//
//  PGiCloudStorage.h
//  PhotoGallery
//
//  Enables "Local data storage <-> iCloud" synchronization
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProxy.h"

@interface ICloudEnabledStorage : DataProxy

@property (nonatomic) BOOL icEnabled;

// directory name for relative data (e.g. photos) on iCloud. Relative data synchronization must be implemented in subclasses.
@property (nonatomic, strong) NSString *iCloudDataDirectory;

// subscribe for notifications on iCloud Core Data changes import
-(void) subscribeForUpdateNotifications: (id)observer selector: (SEL)selector;
-(void) unSubscribeFromUpdateNotifications: (id)observer;


// When CoreData has committed changes, this method will be called to perform all required operations on relative data.
// Currently do nothing. Can be overriden by subclasses.
-(BOOL) performSynkIfRequired;

@end

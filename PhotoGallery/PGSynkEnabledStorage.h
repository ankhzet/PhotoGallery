//
//  PGSynkEnabledStorage.h
//  PhotoGallery
//
//  Enables "Local data storage <-> Remote storage" synchronization
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProxy.h"

@interface PGSynkEnabledStorage : DataProxy

/*! @brief Is synk enabled by user? */
@property BOOL performSynk;

/*! @brief Returns YES, if synk enabled in preferences and remote storage is accessible */
- (BOOL) synkable;

// subscribe for notifications on remote Core Data changes import
-(void) subscribeForUpdateNotifications: (id)observer selector: (SEL)selector;
-(void) unSubscribeFromUpdateNotifications: (id)observer;

// When CoreData has committed changes, this method will be called to perform all required operations on relative data.
// Currently do nothing. Can be overriden by subclasses.
-(BOOL) performSynkIfRequiredFromRemote:(BOOL)fromRemote withChanges:(NSDictionary *)changes;

@end

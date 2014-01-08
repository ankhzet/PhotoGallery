//
//  PGDataPproxyContainer.h
//  PhotoGallery
//
//  This class is used to encapsulate ( or it tries to encapsulate %) ) data managing code (like iCloud sync).
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProxy.h"

@interface PGDataProxyContainer : NSObject

@property (nonatomic, strong) DataProxy *dataProxy;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// singletone instance aquiring. Throws exception, if not configured with +initInstance first.
+(PGDataProxyContainer *) getInstance;

// singletone configuration. Only first call have impact
+(PGDataProxyContainer *) initInstance: (DataProxy *)proxy;

// commit all changes in CoreData storage
+(BOOL) saveContext;

@end

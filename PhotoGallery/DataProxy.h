//
//  DataProxy.h
//  PhotoGallery
//
//  CoreData managing wrapper
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataProxy : NSObject

// CoreData stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// directory name to store local data (photos)
@property (nonatomic, strong) NSString *localDataDirectory;

// file name to store coredata file
@property (nonatomic, strong) NSString *dataStorageFileName;

// flush CoreData to storage...
-(BOOL) saveContext;

// absolute url for local data storage (e.g. database file)
-(NSURL *) localDataDirURL;

// absolute url of local coredata file
-(NSURL *) localStorageFileURL;

- (NSPersistentStore *) addPersistentStore:(NSPersistentStoreCoordinator *)coordinator;

@end

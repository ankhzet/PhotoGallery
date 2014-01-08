//
//  PGiCloudStorage.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "ICloudEnabledStorage.h"
#import "PGUtils.h"

#import "iCloudDownload.h"

@interface ICloudEnabledStorage ()

@end;

@implementation ICloudEnabledStorage

// notofocation, that will be send on iCloud data update
NSString *changeNotificationName = @"CoreDataChangeNotification";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


NSString *iCloudAppID = @"team.author.app";

// init with default data manager.
-(id)init {
    if (!(self = [super init]))
        return self;
    
    self.icEnabled = [self getUbiq] != nil;
    
    self.iCloudDataDirectory = @"Documents";
    
    return self;
}

// Ubiq URL for iCloud container
-(NSURL *) getUbiq {
    return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:iCloudAppID];
}

// absolute url for data files (e.g. photos) on iCloud
-(NSURL *) iCloudDataDirURL {
    return [[self getUbiq] URLByAppendingPathComponent:self.iCloudDataDirectory isDirectory:true];
}


-(BOOL) performSynkIfRequired {
    return YES;
}

-(BOOL) startDownload: (NSString *) fileName withDelegate: (id<iCloudDownloaderDelegate>) delegate {
    NSURL *remoteFile = [[self iCloudDataDirURL] URLByAppendingPathComponent:fileName];
    NSURL *localFile = [[self localDataDirURL] URLByAppendingPathComponent:fileName];
    iCloudDownload *downloader = [[iCloudDownload alloc] initWithCloudFileURL:remoteFile localFileURL:localFile andDelegate:delegate];
    return [downloader startDownload];
}

#pragma mark - CoreData relative methods override

-(NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if(_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    
    // Set up iCloud in another thread:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *localStore = [self localStorageFileURL]; // absolute url
        NSURL *iCloud = [self getUbiq];
        
        if (iCloud) {
            
            NSLog(@"iCloud-enabled device");
            
            NSLog(@"iCloudAppID = %@", iCloudAppID);
            NSLog(@"localDataStorageFile = %@", self.dataStorageFileName);
            NSLog(@"iCloudDataDirectoryName = %@", self.iCloudDataDirectory);
            NSLog(@"iCloud = %@", iCloud);
            
            NSString *iCloudDataDir = [[self iCloudDataDirURL] path];
            
            if ([fileManager fileExistsAtPath:iCloudDataDir isDirectory:YES] == NO) {
                NSError *fileSystemError;
                [fileManager createDirectoryAtPath:iCloudDataDir
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&fileSystemError];
                if (fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }
            
            NSURL *iCloudData = [[self iCloudDataDirURL] URLByAppendingPathComponent:self.dataStorageFileName];
            
            NSLog(@"iCloudData = %@", iCloudData);
            
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            [options setObject:iCloudAppID                   forKey:NSPersistentStoreUbiquitousContentNameKey];
            
            [psc lock];

            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:iCloudData
                                    options:options
                                      error:nil];
            
            [psc unlock];
        }
        else {
            NSLog(@"Not an iCloud-enabled device - using a local store");
            NSLog(@"localDataStorageFile = %@", self.dataStorageFileName);

            NSMutableDictionary *options = nil;[NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:localStore
                                    options:options
                                      error:nil];
            [psc unlock];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyChangedWithUserInfo:nil];
        });
    });
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudChangesImport:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
    
    return _managedObjectContext;
}

- (void)iCloudChangesImport:(NSNotification *)notification {
    NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
        if (![self saveContext])
            NSLog(@"Strange CoreData behavior, context save after merge failed.");
        else
            [self notifyChangedWithUserInfo:[notification userInfo]];
    }];
}

-(void) notifyChangedWithUserInfo: (id) userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:changeNotificationName object:self userInfo:userInfo];
}

-(void) subscribeForUpdateNotifications: (id)observer selector: (SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:changeNotificationName
                                               object:self];
    
}
-(void) unSubscribeFromUpdateNotifications: (id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:changeNotificationName object:self];
    
}

// save CoreData db updates. If there are added photos - they will be pushed on iCloud.
-(BOOL) saveContext {
    BOOL saved = [super saveContext];
    
    if (saved) {
        [self performSynkIfRequired];
    }
    
    return saved;
}

@end

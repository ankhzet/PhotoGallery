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
@property (strong) NSURL *ubiq;
@property BOOL useiCloud;
@end;

@implementation ICloudEnabledStorage

// notification, that will be send on iCloud data update
NSString *changeNotificationName = @"CoreDataChangeNotification";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


NSString *iCloudAppID = @"team.author.app";

// init with default data manager.
-(id)init {
	if (!(self = [super init]))
		return self;
	
	self.useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudSynchronization"];
	self.icEnabled = [self getUbiq] != nil;
	
	self.iCloudDataDirectory = nil;
	
	return self;
}

// Reusable ubiq URL for iCloud container
-(NSURL *) getUbiq {
	if (!self.ubiq)
		self.ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:iCloudAppID];
	
	return self.ubiq;
}

// absolute url for data files (e.g. photos) on iCloud
-(NSURL *) iCloudDataDirURL {
	if (!self.iCloudDataDirectory || [self.iCloudDataDirectory isEqualToString:@""])
		return [self getUbiq]; // use root "/Documents/" directory by default
	else
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

// Metods returns persistent storage coordinator if it was created previously. Otherwise, new coordinator will be created. If device is iCloud-enabled, iCloud-synched store will be added to coordinator. Method returns immediately, store setup made in separate thread, after setup update notification will ne sent to observers (see (un)subscribeForUpdateNotifications method).
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
		
		if (self.useiCloud && self.icEnabled) {
			NSURL *iCloud = [self getUbiq];
			
			NSLog(@"iCloud-enabled device");
			
			NSLog(@"iCloudAppID = %@", iCloudAppID);
			NSLog(@"localDataStorageFile = %@", self.dataStorageFileName);
			NSLog(@"iCloudDataDirectoryName = %@", self.iCloudDataDirectory ? self.iCloudDataDirectory : @"Documents");
			NSLog(@"iCloud = %@", iCloud);
			
			NSString *iCloudDataDir = [[self iCloudDataDirURL] path];
			
			// create iCloud directory for database, if required
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
			
			// options for persistent store
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
			NSLog(@"Not an iCloud-enabled device (or disabled in preferences) - using a local store");
			NSLog(@"localDataStorageFile = %@", self.dataStorageFileName);
			
			// options for persistent store
			NSMutableDictionary *options = [NSMutableDictionary dictionary];
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
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self notifyChangedWithUserInfo:nil];
		});
	});
	
	return _persistentStoreCoordinator;
}

- (void) userDefaultsChanged: (NSNotification *) notification {
	BOOL oldPref = self.useiCloud;
	self.useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudSynchronization"];
	
	// try to recreate Core Data managers
	if (oldPref != self.useiCloud) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
		_managedObjectContext = nil;
		_persistentStoreCoordinator = nil;
		[self managedObjectContext];
	}
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


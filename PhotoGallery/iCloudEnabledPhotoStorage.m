//
//  iCloudEnabledPhotoStorage.m
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "iCloudEnabledPhotoStorage.h"
#import "iCloudDownload.h"

@interface iCloudEnabledPhotoStorage ()

@property (nonatomic, strong) NSMetadataQuery *synkQuery;
@property (strong) NSURL *ubiq;

@end

@implementation iCloudEnabledPhotoStorage

NSString *iCloudAppID = @"team.author.app";

// Pattern to pick photo files from iCloud
NSString *storedFilePattern = @"*.jpg";

-(id)init {
	if (!(self = [super init]))
		return nil;
	
	self.iCloudDataDirectory = nil;
	self.icEnabled = [self getUbiq];

	// override superclass defaults
	self.dataStorageFileName = @"PhotoGallery.sqlite";
	
	// is there a better way? sync dir <-> dir, not files <-> files
	self.localDataDirectory = @"Photos"; // result will be "Application:/Documents/Photos"
	self.iCloudDataDirectory = @"Photos"; // result will be "iCloud:/Documents/Photos"
	
	return self;
}

-(BOOL) performSynkIfRequired {
	if (!(self.icEnabled && !self.synkQuery))
		return NO;
	
	NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
	
	[query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K like %@", NSMetadataItemFSNameKey, storedFilePattern];
	NSLog(@"Predic: %@", predicate);
	[query setPredicate:predicate];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(queryDidFinishGathering:)
																							 name:NSMetadataQueryDidFinishGatheringNotification
																						 object:query];
	
	// no need for sorting
	BOOL queryStarted = [query startQuery];
	if (queryStarted)
		self.synkQuery = query;
	
	return queryStarted;
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
	NSMetadataQuery *query = [notification object];
	[query disableUpdates];
	[query stopQuery];
	
	[self processQuery:query];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
	
	self.synkQuery = nil;
}

// process file list from remote iCloud storage and get diffs
-(void)processQuery: (NSMetadataQuery *) query {
	NSMutableArray *data = [NSMutableArray array];
	
	for (NSMetadataItem *item in [query results]) {
		NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
		
		[data addObject:url];
	}
	
	NSLog(@"Total fetched: %@", data);
	
	// TODO: implement photo files sync code
	
	// first: fetch photo entities from coredata
	
	// second: for photos, that was arrived from iCloud - pull photo files from iCloud
	
	// third: for photos, that present only localy - push photo files onto iCloud
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

-(BOOL) startDownload: (NSString *) fileName withDelegate: (id<iCloudDownloaderDelegate>) delegate {
	NSURL *remoteFile = [[self iCloudDataDirURL] URLByAppendingPathComponent:fileName];
	NSURL *localFile = [[self localDataDirURL] URLByAppendingPathComponent:fileName];
	iCloudDownload *downloader = [[iCloudDownload alloc] initWithCloudFileURL:remoteFile localFileURL:localFile andDelegate:delegate];
	return [downloader startDownload];
}

- (NSPersistentStore *) configureRemoteStore:(NSPersistentStoreCoordinator *)coordinator {
	NSURL *iCloud = [self getUbiq];

	NSLog(@"iCloud-enabled device");

	NSLog(@"iCloudAppID = %@", iCloudAppID);
	NSLog(@"localDataStorageFile = %@", self.dataStorageFileName);
	NSLog(@"iCloudDataDirectoryName = %@", self.iCloudDataDirectory ? self.iCloudDataDirectory : @"Documents");
	NSLog(@"iCloud = %@", iCloud);

	NSString *iCloudDataDir = [[self iCloudDataDirURL] path];
	NSFileManager *fileManager = [NSFileManager defaultManager];

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

	NSURL *iCloudDataStorage = [[self iCloudDataDirURL] URLByAppendingPathComponent:self.dataStorageFileName];

	NSLog(@"iCloudDataStorage = %@", iCloudDataStorage);

	// options for persistent store
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	[options setObject:iCloudAppID                   forKey:NSPersistentStoreUbiquitousContentNameKey];

	[coordinator lock];

	NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
										configuration:nil
															URL:iCloudDataStorage
													options:options
														error:nil];

	[coordinator unlock];
	return store;
}

- (BOOL) synkable {
	return self.performSynk && self.icEnabled;
}

@end

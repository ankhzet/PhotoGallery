//
//  PGDropBoxSynkedStorage.m
//  PhotoGallery
//
//  Created by Ankh on 03.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGDropBoxSynkedStorage.h"
#import "Photo.h"
#import <ParcelKit/ParcelKit.h>
#import <Foundation/Foundation.h>

const NSString *kPGDBAppKey = @"kPGDBAppKey";
const NSString *kPGDBAppSecret = @"kPGDBAppSecret";

@interface PGDropBoxSynkedStorage () {
	NSMutableArray *scheduledSynks;
}
@property BOOL ready;
@property (atomic, readonly) PKSyncManager *syncManager;
@property (atomic, readonly) DBDatastore *datastore;
@property (atomic, readonly) NSString *appKey;
@property (atomic, readonly) NSString *appSecret;
@end

@implementation PGDropBoxSynkedStorage
@synthesize dropboxEnabled = _dropboxEnabled;
@synthesize datastore = _datastore;
@synthesize ready = _ready;

+ (instancetype) storageForDBApp:(NSDictionary *)appParameters {
	return [[self alloc] initForDBApp:appParameters];
}

- (id)initForDBApp:(NSDictionary *)appParameters {
	if (!(self = [super init]))
		return nil;

	scheduledSynks = [NSMutableArray array];
	self.ready = NO;

	// override superclass defaults
	self.dataStorageFileName = @"PhotoGallery.sqlite";

	// is there a better way? sync dir <-> dir, not files <-> files
	self.localDataDirectory = @"Photos"; // result will be "Application:/Documents/Photos"

	_appKey = appParameters[kPGDBAppKey];
	_appSecret = appParameters[kPGDBAppSecret];
	_dropboxEnabled = self.performSynk && !![self getDBAccount];
	return self;
}

-(NSString *) filterDiff:(NSManagedObject *)entity {
	BOOL isLinkedEntity = [entity isKindOfClass:[Photo class]];
	return isLinkedEntity ? ((Photo *)entity).fileName : nil;
}

- (BOOL) synkable {
	return self.performSynk && self.dropboxEnabled;
}

- (void) synkToggled {
	if ([self performSynk]) {
		_dropboxEnabled = !![self getDBAccount];
		if (_dropboxEnabled) {
			_syncManager = [[PKSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:self.datastore];
			[_syncManager setTable:@"photos" forEntityName:@"Photo"];

			[[NSNotificationCenter defaultCenter]
			 addObserver:self
			 		selector:@selector(onCoreDataChanges:)
			 				name:PKSyncManagerDatastoreChangesNotification
						object:nil];

		}
		[_syncManager startObserving];
	} else {
		[_syncManager stopObserving];
		_syncManager = nil;
		[[DBAccountManager sharedManager] removeObserver:self];
	}
}

- (void) handleSynk:(NSDictionary *)synk {
	NSDictionary *changes  = synk[PKSyncManagerDatastoreChangesKey];
	NSDictionary *incoming = synk[PKSyncManagerDatastoreIncomingChangesKey];
	NSDictionary *outgoing = synk[PKSyncManagerDatastoreOutgoingChangesKey];

	[self performSynkIfRequiredFromRemote:YES withChanges:incoming];
	[self performSynkIfRequiredFromRemote:NO withChanges:outgoing];

	NSLog(@"changes: %@", changes);
	NSLog(@"incoming: %@", incoming);
	NSLog(@"outgoing: %@", outgoing);

	[self notifyChangedWithUserInfo:synk];

	id appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate && incoming) {
		NSUInteger inserted = [incoming[NSInsertedObjectsKey] count];
		NSUInteger deleted = [incoming[NSDeletedObjectsKey] count];
		NSUInteger updated = [incoming[NSUpdatedObjectsKey] count];
		if (inserted + deleted + updated > 0) {
			[appDelegate onIncomingChanges];
		}
	}

}

- (void) setReady:(BOOL)ready {
	if (ready != _ready) {
		if (ready) {
			// when dropbox filesystem is ready (completed first synk),
			// storage should handle scheduled synk checks
			@synchronized(scheduledSynks) {
				for (NSDictionary *synk in scheduledSynks) {
					[self handleSynk:synk];
				}
				[scheduledSynks removeAllObjects];
			}
		}

		_ready = ready;
	}
}

- (BOOL) ready {
	return _ready;
}

- (void) onCoreDataChanges:(NSNotification *) notif {
	// dropbox filesystem can be not ready yet
	@synchronized(scheduledSynks) {
		if (!self.ready) {
			// schedule synk check
			[scheduledSynks addObject:notif.userInfo];
			return;
		}
	}

	// ... or handle it immediately
	[self handleSynk:notif.userInfo];
}

- (DBDatastore *) datastore {
	if (_datastore)
		return _datastore;

	DBError *error = nil;
	_datastore = [DBDatastore openDefaultStoreForAccount:[self getDBAccount] error:&error];
	if (!_datastore) {
		NSLog(@"DBDatastore creation error: %@", error);
	}
	return _datastore;
}

/*!
 @brief Aquire DropBox account data.
 */
- (DBAccount *) getDBAccount {
	// init account manager for dropbox app, if not yet
	DBAccountManager *accountManager = [DBAccountManager sharedManager];
	if (!accountManager) {
		accountManager = [[DBAccountManager alloc] initWithAppKey:self.appKey secret:self.appSecret];
		[DBAccountManager setSharedManager:accountManager];
	}

	DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
	if (account) {
		// already logined & linked
		return account;
	}

	[self reSubscribeSynkForLogins];

	// try to login
	if (!account) {
		id appDelegate = [[UIApplication sharedApplication] delegate];
		NSAssert([appDelegate conformsToProtocol:@protocol(PGDBSynkedApplicationDelegate)], @"AppDelegate should conform to PGDBSynkedApplicationDelegate protocol");

		[self reSubscribeSynkForLogins];
		[[DBAccountManager sharedManager] linkFromController:[appDelegate rootControllerForLoginView]];
	}

	return account;
}

/*!
 @brief Observe logins, to make sure synk is turned off when log out & turned on when log in.
 */
- (void) reSubscribeSynkForLogins {
	DBAccountManager *accountManager = [DBAccountManager sharedManager];
	[accountManager removeObserver:self];

	__weak typeof(self) weakSelf = self;
	[accountManager addObserver:self block:^(DBAccount *account) {
		typeof(self) strongSelf = weakSelf; if (!strongSelf) return;

		if ([account isLinked]) {
			DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
			[DBFilesystem setSharedFilesystem:filesystem];
			[filesystem addObserver:self block:^{
				if ([[DBFilesystem sharedFilesystem] completedFirstSync]) {
					strongSelf.ready = YES;
				}
			}];
		} else
			[DBFilesystem setSharedFilesystem:nil];

		NSLog(@"%@ account: %@", ([account isLinked]) ? @"Linked" : @"Unlinked", account);
		_datastore = nil;
		[strongSelf setPerformSynk:[account isLinked]];
	}];
	
}

-(PGFileSynkState) fileState:(NSString *)fileName {
	PGFileSynkState state = PGFileSynkStateNone;
	DBPath *path = [[DBPath root] childPath:fileName];
	DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
	if (file) {
		DBFileStatus *status = [file status];
		if (status.cached && (status.state != DBFileStateDownloading)) {
			state = PGFileSynkStateIsLocal;
		} else
			state = PGFileSynkStateIsRemote;

		if (status.state == DBFileStateDownloading) state |= PGFileSynkStateDownloading;
		if (status.state == DBFileStateUploading) state |= PGFileSynkStateUploading;
	} else {
		NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:fileName];

		state = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]] ? PGFileSynkStateIsLocal : PGFileSynkStateNone;
	}
	return state;
}

-(PGFileSynkState) fileDownload:(NSString *)fileName {
	DBPath *path = [[DBPath root] childPath:fileName];
	DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
	if (file) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:fileName];
			DBError *error = nil;
			NSData *data = [file readData:&error];

			BOOL downloaded = [data writeToURL:fileURL atomically:YES];
			if (!downloaded) {
				NSLog(@"Download %@ failed: %@", fileName, error);
			}
		});
		return PGFileSynkStateDownloading;
	}
	return PGFileSynkStateIsRemote;
}

-(PGFileSynkState) fileUpload:(NSString *)fileName {
	DBPath *path = [[DBPath root] childPath:fileName];
	DBError *error = nil;
	__weak DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&error];
	if (!file) {
		file = [[DBFilesystem sharedFilesystem] createFile:path error:&error];
	}
	if (file) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:fileName];
			DBError *error = nil;
			[file addObserver:self block:^() {
        NSLog(@"%@", file.status);
			}];
			BOOL uploaded = [file writeContentsOfFile:[fileURL path] shouldSteal:NO error:&error];
			if (!uploaded) {
				NSLog(@"Upload %@ failed: %@", fileName, error);
			}
		});
		return PGFileSynkStateUploading;
	} else {
		NSLog(@"record creation error: %@", error);
	}
	return PGFileSynkStateIsLocal;
}

@end

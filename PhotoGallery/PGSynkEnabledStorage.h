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

typedef NS_ENUM(NSUInteger, PGFileSynkState) {
	PGFileSynkStateNone        = 1 << 0,
	PGFileSynkStateIsRemote    = 1 << 1,
	PGFileSynkStateIsLocal     = 1 << 2,
	PGFileSynkStateUploading   = 1 << 3,
	PGFileSynkStateDownloading = 1 << 4,
};

@interface PGSynkEnabledStorage : DataProxy

/*! @brief Is synk enabled by user? */
@property (atomic) BOOL performSynk;

/*! @brief Returns YES, if synk enabled in preferences and remote storage is accessible */
- (BOOL) synkable;

/*!
 @brief Notify storage about synk state changes.
 */
- (void) synkToggled;

-(void) notifyChangedWithUserInfo: (id) userInfo;

// subscribe for notifications on remote Core Data changes import
-(void) subscribeForUpdateNotifications: (id)observer selector: (SEL)selector;
-(void) unSubscribeFromUpdateNotifications: (id)observer;

// When CoreData has committed changes, this method will be called to perform all required operations on relative data.
// Currently do nothing. Can be overriden by subclasses.
-(BOOL) performSynkIfRequiredFromRemote:(BOOL)fromRemote withChanges:(NSDictionary *)changes;

/*!
 @brief Filter CoreData entities, that are not linked with files.
 */
-(NSString *) filterDiff:(NSManagedObject *)entity;
/*!
 @brief Returns current file (& synk) state: local, remote, uploading, downloading, unknown (none).
 */
-(PGFileSynkState) fileState:(NSString *)fileName;
/*!
 @brief Force file download process.
 @return
 `PGFileSynkStateDownloading`, if download scheduled or already cached.
 `PGFileSynkStateIsRemote` if -[DBFilesystem openFile:error:] failed.
 */
-(PGFileSynkState) fileDownload:(NSString *)fileName;
/*!
 @brief Force file upload process.
 @return
 `PGFileSynkStateUploading`, if upload scheduled.
 `PGFileSynkStateIsLocal` if cannot open file.
 */
-(PGFileSynkState) fileUpload:(NSString *)fileName;

@end

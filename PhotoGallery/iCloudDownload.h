//
//  iCloudDownload.h
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>


@class iCloudDownload;

@protocol iCloudDownloaderDelegate <NSObject>

-(void) downloadStarted: (iCloudDownload *) downloader;
-(void) downloadFailed: (iCloudDownload *) downloader;
-(void) downloadFinished: (iCloudDownload *) downloader;

@end

@interface iCloudDownload : NSObject

@property (nonatomic, strong) NSURL *remoteFileURL;
@property (nonatomic, strong) NSURL *localFileURL;
@property (nonatomic, weak) id<iCloudDownloaderDelegate> delegate;

// prepare download for specified iCloud URL. Delegate may be nil.
-(id) initWithCloudFileURL: (NSURL *) fileURL localFileURL: (NSURL *)localURL andDelegate: (id<iCloudDownloaderDelegate>) delegate;

// Configure iCloud to synchronize managed file (or not to). Returns YES, if status successfuly updated (not uploaded or downloaded file, just changed status). Also links remote URL with local, if needed.
-(BOOL) setSyncNeeded: (BOOL) needed;

// check iCloud file for existance, status etc.
-(BOOL) isFilePresent;
-(BOOL) isFileDownloaded;
-(BOOL) isFileDownloading;

// Start download process. Return NO, if already downloading, downloaded or download failed (use filePresent and fileDownloading(-ed) to find out the source of problem).

-(BOOL) startDownload;

@end


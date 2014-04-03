//
//  iCloudDownload.m
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "iCloudDownload.h"

@interface iCloudDownload ()

@property (nonatomic, strong) NSTimer *checkTimer;

@end

@implementation iCloudDownload

-(id) initWithCloudFileURL: (NSURL *) fileURL localFileURL: (NSURL *)localURL andDelegate: (id<iCloudDownloaderDelegate>) delegate {
	if (!(self = [super init]))
		return nil;
	
	self.remoteFileURL = fileURL;
	self.localFileURL = localURL;
	self.delegate = delegate;
	
	return self;
}

-(BOOL) isFilePresent {
	NSNumber *presentOnRemote = nil;
	return [self.remoteFileURL getResourceValue:&presentOnRemote forKey:NSURLIsUbiquitousItemKey error:nil] && [presentOnRemote boolValue];
}

-(BOOL) isFileDownloaded {
	NSNumber *isDownloaded = nil;
	return [self.remoteFileURL getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil] && [isDownloaded boolValue];
}

-(BOOL) isFileDownloading {
	NSNumber *isDownloading = nil;
	return [self.remoteFileURL getResourceValue:&isDownloading forKey:NSURLUbiquitousItemIsDownloadingKey error:nil] && [isDownloading boolValue];
}

// Configure iCloud to sync managed file or not. Returns YES, if status successfuly updated (not uploaded or downloaded file, just changed status).
-(BOOL) setSyncNeeded: (BOOL) needed {
	NSError *error = nil;
	if (![[NSFileManager defaultManager] setUbiquitous:true itemAtURL:self.localFileURL destinationURL:self.remoteFileURL error:&error]) {
		NSLog(@"iCloud Sync error: %@", [error localizedDescription]);
		
		return NO;
	}
	return YES;
}

// Start download process. Return NO, if already downloading, downloaded or download failed (use filePresent and fileDownloading(-ed) to find out the source of problem).
-(BOOL) startDownload {
	if ((![self isFilePresent]) || [self isFileDownloading] || [self isFileDownloaded])
		return NO;
	
	// start downloading
	NSError *error = nil;
	BOOL isDownloadStarted = [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:self.remoteFileURL error:&error];
	
	NSLog(@"started download for [%@] %d", [self.remoteFileURL lastPathComponent], isDownloadStarted);
	
	if (isDownloadStarted) {
		[self downloadStarted]; // notify delegate
		return [self downloadIteration:nil];
	} else {
		NSLog(@"iCloud file download error: %@", [error localizedDescription]);
	}
	
	return isDownloadStarted;
}

// download check iteration. if download finished, or file dissappeared from iCloud - notify delegate, else - requeue download check.
-(BOOL) downloadIteration:(NSTimer *)timer {
	if ([self isFilePresent]) {
		if ([self isFileDownloaded]) {
			[self downloadFinished]; // notify delegate, if any
			return YES;
		}
		
		[self delayedCheck]; // queue next check iteration
	} else {
		[self downloadFailed]; // notify delegate
		return NO;
	}
	
	return YES;
}

// start new timer to check for download progress
-(void) delayedCheck {
	[self dropTimer]; // drop old timer if it's still alive
	self.checkTimer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(downloadIteration) userInfo:nil repeats:NO];
	
	if (self.checkTimer)
		[[NSRunLoop currentRunLoop] addTimer:self.checkTimer forMode:NSDefaultRunLoopMode];
}

-(void) dropTimer {
	[self.checkTimer invalidate]; // not forget to remove circular reference...
	self.checkTimer = nil; // just for sure...
}

// selector-fail-safe proxy
-(void) downloadStarted {
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloadStarted)]) // not sure it's ok %)
		[self.delegate downloadStarted:self];
}

// ...
-(void) downloadFinished {
	[self dropTimer];
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFinished)])
		[self.delegate downloadFinished:self];
}

// ...
-(void) downloadFailed {
	[self dropTimer];
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFailed)])
		[self.delegate downloadFailed:self];
}

@end

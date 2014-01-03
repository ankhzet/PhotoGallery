//
//  PGiCloudStorage.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGiCloudStorage.h"

@interface PGiCloudStorage ()
@property (nonatomic, weak) NSFileManager *fileManager;
@property (nonatomic) BOOL icConnected;
@property (nonatomic, strong) NSMetadataQuery *synkQuery;

@end;

@implementation PGiCloudStorage

NSURL *localURL;


// init with default data manager.
-(id)init {
    if (!(self = [super init]))
        return self;
    
    _fileManager = [NSFileManager defaultManager];
    _icConnected = [self getUbiq] != nil;
    
    localURL = [NSURL URLWithString:@"Documents/PhotoGallery/"];
    
    return self;
}

// Pattern to pick database file from iCloud
+(NSString *) databaseFile {
    return @"*.db";
}

// Pattern to pick photo files from iCloud
+(NSString *) storedFile {
    return @"*.jpg";
}

// Ubiq URL for iCloud container
-(NSURL *) getUbiq {
    return [self.fileManager URLForUbiquityContainerIdentifier:nil];
    
}

-(void) synkWithICloud:(NSString *) fileName {
    NSURL *ubiq = [self getUbiq];
    
    NSURL *iCloudURL = [ubiq URLByAppendingPathComponent:@"Documents" isDirectory:true];
    NSURL *iCloudFile = [iCloudURL URLByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    
    [self.fileManager setUbiquitous:true itemAtURL:localURL destinationURL:iCloudFile error:&error];
    

}

-(BOOL) startSynk {
    if (!self.icConnected)
        return NO;
    
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    
    [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K like %@", NSMetadataItemFSNameKey, [PGiCloudStorage databaseFile]];
    
    NSLog(@"Predic: %@", predicate);
    [query setPredicate:predicate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(queryDidStartGathering:)
//                                                 name:NSMetadataQueryDidStartGatheringNotification
//                                               object:query];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(queryDidUpdateNotification:)
//                                                 name:NSMetadataQueryDidUpdateNotification
//                                               object:query];
    
    BOOL queryStarted = [query startQuery];
    if (queryStarted)
        self.synkQuery = query;
    
    return queryStarted;
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    self.synkQuery = nil;
}

//- (void)queryDidStartGathering:(NSNotification *)notification {
//
//}
//
//- (void)queryDidUpdateNotification:(NSNotification *)notification {
//
//}

-(void)loadData: (NSMetadataQuery *) query {
    NSMutableArray *data = [NSMutableArray array];
    [data removeAllObjects];
    
    for (NSMetadataItem *item in [query results]) {
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSLog(@"Fetched item:\n%@", item);
        [data addObject:url.lastPathComponent];
    }
    
    NSLog(@"Total fetched: %@", data);
    
//    [_table reloadData];
//    
//    [self.loadingBackupIndicator stopAnimating];
//    self.loadingIndicatorLabel.text = [NSString stringWithFormat: @"%d backups found", [self.backups count]];

}

-(void) downloadFile {
//    NSFileManager *fm = [NSFileManager defaultManager];
//    
//    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//    
//    if (ubiq == nil) {
//        return NO;
//    }
//    
//    NSError *theError = nil;
//    
//    bool started = [fm startDownloadingUbiquitousItemAtURL:[[ubiq URLByAppendingPathComponent:@"Documents" isDirectory:true] URLByAppendingPathComponent:backupName] error:&theError];
//    
//    NSLog(@"started download for %@ %d", backupName, started);
//    
//    if (theError != nil) {
//        NSLog(@"iCloud error: %@", [theError localizedDescription]);
//    }
}

-(void) fileDownloading {
//    NSNumber *isIniCloud = nil;
//    
//    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//    
//    NSURL *file = [[ubiq URLByAppendingPathComponent:@"Documents" isDirectory:true] URLByAppendingPathComponent:self.backupName];
//    
//    if ([file getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
//        // If the item is in iCloud, see if it is downloaded.
//        if ([isIniCloud boolValue]) {
//            NSNumber*  isDownloaded = nil;
//            if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil]) {
//                if ([isDownloaded boolValue]) {
//                    [self.loadingBackupIndicator stopAnimating];
//                    self.loadingIndicatorLabel.text = @"Downloaded";
//                    
//                    ....
//                    
//                    [[NSFileManager defaultManager] copyItemAtPath:[file path] toPath:restorePath error:&theError ];
//                    
//                    ....
//                    
//                    return YES;
//                }
//                
//                self.loadingCheckTimer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(downloadFileIfNotAvailable) userInfo:nil repeats:NO];
//                [[NSRunLoop currentRunLoop] addTimer:self.loadingCheckTimer forMode:NSDefaultRunLoopMode];
//                
//                return NO;
//            }
//        }
//    }
//    
//    return YES;
}

@end

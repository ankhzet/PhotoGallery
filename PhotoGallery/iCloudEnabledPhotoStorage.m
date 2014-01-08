//
//  iCloudEnabledPhotoStorage.m
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "iCloudEnabledPhotoStorage.h"

@interface ICloudEnabledStorage ()

@property (nonatomic, strong) NSMetadataQuery *synkQuery;

@end

@implementation iCloudEnabledPhotoStorage

// Pattern to pick photo files from iCloud
NSString *storedFilePattern = @"*.jpg";

-(id)init {
    if (!(self = [super init]))
        return nil;
    
    // override superclass defaults
    self.localDataDirectory = @"Photos";
    self.dataStorageFileName = @"PhotoGallery.sqlite";

    self.iCloudDataDirectory = @"PhotoGallery";
    
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

@end

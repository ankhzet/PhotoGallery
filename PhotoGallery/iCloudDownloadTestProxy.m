//
//  iCloudDownloadTestProxy.m
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "iCloudDownloadTestProxy.h"

@interface iCloudDownloadTestProxy ()
@property (nonatomic) BOOL downloaded;
@end

@implementation iCloudDownloadTestProxy

-(id)init {
    if (!(self = [super init]))
        return nil;
    
    self.downloaded = NO;
    
    return self;
}

-(BOOL) isFilePresent {
    // assume, that file esists on fake iCloud...
    return YES;
}

-(BOOL) isFileDownloaded {
    if (self.downloaded)
        return YES;
    
    self.downloaded = arc4random() % 100 > 66;
    if (self.downloaded) {
        [[NSFileManager defaultManager] copyItemAtURL:[[NSBundle mainBundle]URLForResource:@"strange" withExtension:@".png"] toURL:self.localFileURL error:nil];
    }
    return self.downloaded;
}

-(BOOL) isFileDownloading {
    return !self.downloaded;
}


@end

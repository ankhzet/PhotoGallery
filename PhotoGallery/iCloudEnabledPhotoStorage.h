//
//  iCloudEnabledPhotoStorage.h
//  PhotoGallery
//
//  Implement storage logic, that is PhotoGallery <-> iCloud specific.
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGSynkEnabledStorage.h"

@interface iCloudEnabledPhotoStorage : PGSynkEnabledStorage

@property (nonatomic) BOOL icEnabled;

// directory name for relative data (e.g. photos) on iCloud. Relative data synchronization must be implemented in subclasses.
@property (nonatomic, strong) NSString *iCloudDataDirectory;


@end

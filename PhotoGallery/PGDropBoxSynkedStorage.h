//
//  PGDropBoxSynkedStorage.h
//  PhotoGallery
//
//  Created by Ankh on 03.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGSynkEnabledStorage.h"

/*!@brief DropBox application key parameter */
extern NSString *kPGDBAppKey;
/*!@brief DropBox application secret paramenter */
extern NSString *kPGDBAppSecret;

/*!
 @brief Delegate to support synk functionality on application level.
 */
@protocol PGDBSynkedApplicationDelegate <NSObject>

/*!
 @brief Returns root view cotnroller to show dropbox login view on top of it.
 */
- (UIViewController *) rootControllerForLoginView;

/*!
 @brief Update UI and stuff on incoming CoreData changes.
 */
- (void) onIncomingChanges;

@end

@interface PGDropBoxSynkedStorage : PGSynkEnabledStorage
@property (nonatomic, readonly) BOOL dropboxEnabled;

/*!
 @brief Instantiates new DropBox-synked storage.
 @param appParameters Application parameters, like app-key (kPGDBAppKey parameter) and app-secret (kPGDBAppSecret parameter).
 */
+ (instancetype) storageForDBApp:(NSDictionary *)appParameters;

@end

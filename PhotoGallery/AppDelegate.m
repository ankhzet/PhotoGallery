//
//  AppDelegate.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AppDelegate.h"

#import "PGDataProxyContainer.h"
#import "iCloudEnabledPhotoStorage.h"

#import "PGUtils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// initializing our data manager
	[PGDataProxyContainer initInstance:[[iCloudEnabledPhotoStorage alloc] init]];
	return YES;
}

// suspend application
- (void)applicationWillResignActive:(UIApplication *)application
{
	
}

// save all data & preferences
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[PGDataProxyContainer saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// undo enter background
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// undo resign active
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[PGDataProxyContainer saveContext];
}

@end

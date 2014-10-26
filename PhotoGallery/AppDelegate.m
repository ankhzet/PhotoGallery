//
//  AppDelegate.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AppDelegate.h"

#import "PGDataProxyContainer.h"

#import "PGUtils.h"
#import "PGShareKitConfigurator.h"
#import <SHKConfiguration.h>
#import <ParcelKit/ParcelKit.h>
#import "PreferencesViewController.h"
#import "PhotoGalleryViewController.h"

@interface AppDelegate ()
@property UIViewController *rootCtl;
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// initializing our data manager
	PGDropBoxSynkedStorage *storage = [PGDropBoxSynkedStorage storageForDBApp:@{kPGDBAppKey: @"y0rdisp1gq22ohe",
																																					 kPGDBAppSecret: @"urr5cn7a0ee0rm1"}];
	[PGDataProxyContainer initInstance:storage];
	[storage subscribeForUpdateNotifications:self selector:@selector(synkNotification:)];
	[storage synkToggled];
	
	// initializing socials configurator
	[SHKConfiguration sharedInstanceWithConfigurator:[[PGShareKitConfigurator alloc]init]];

	// dirty hack
	UINavigationController *nav = (id)self.window.rootViewController;
	self.rootCtl = nav.topViewController;

	return YES;
}

- (void) synkNotification:(NSNotification *)notification {
	PhotoGalleryViewController *rootView = (id)self.rootCtl;
	[rootView reloadTable];
}

- (UIViewController *) rootControllerForLoginView {
	return [PreferencesViewController instance];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url	sourceApplication:(NSString *)source annotation:(id)annotation {
	return !![[DBAccountManager sharedManager] handleOpenURL:url];
}

- (void) onIncomingChanges {
	NSLog(@"Changes");
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

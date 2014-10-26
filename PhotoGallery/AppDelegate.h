//
//  AppDelegate.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGDropBoxSynkedStorage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PGDBSynkedApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

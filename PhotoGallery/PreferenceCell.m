//
//  PreferenceCell.m
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PreferenceCell.h"

@implementation PreferenceCell

+ (id) newCell {
	return [[super alloc] init];
}

- (void) configureCell: (NSString *) identifier withPreferences: (NSUserDefaults *) preferences withTitle: (NSString *) title {
	//  remember for later use
	self.preferences = preferences;
	self.preferenceIdentifier = identifier;
	
	[self.preferenceTitle setText:title];
}

@end


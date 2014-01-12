//
//  SwitchPreferenceCell.m
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "SwitchPreferenceCell.h"

@implementation SwitchPreferenceCell

// Returns new SwitchPreferenceCell, instantiated from .nib file.
+ (id) newCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SwitchPreferenceCell" owner:nil options:nil];
	
	return nib[0];
}

- (void) configureCell: (NSString *) identifier withPreferences: (NSUserDefaults *) preferences withTitle: (NSString *) title {
	[super configureCell:identifier withPreferences:preferences withTitle:title];
	[self.preferenceValue setOn:[preferences boolForKey:identifier]];
}

- (IBAction)valueChanged:(id)sender {
	[self.preferences setBool:[self.preferenceValue isOn] forKey:self.preferenceIdentifier];
}

@end

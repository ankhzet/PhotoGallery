//
//  StringPreferenceCell.m
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "StringPreferenceCell.h"

@implementation StringPreferenceCell

// Returns new StringPreferenceCell object, instantiated from .nib file.
+ (id) newCell {
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StringPreferenceCell" owner:nil options:nil];
	
	return nib[0];
}

- (void) configureCell: (NSString *) identifier withPreferences: (NSUserDefaults *) preferences withTitle: (NSString *) title {
	[super configureCell:identifier withPreferences:preferences withTitle:title];
	[self.preferenceValue setText:[preferences stringForKey:identifier]];
}

// on value change - save changes to user defaults object
- (IBAction)valueChanged:(id)sender {
	[self.preferences setObject:[self.preferenceValue text] forKey:self.preferenceIdentifier];
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
	[sender resignFirstResponder];
	return NO;
}

@end

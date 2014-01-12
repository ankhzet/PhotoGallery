//
//  StringPreferenceCell.h
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferenceCell.h"

@interface StringPreferenceCell : PreferenceCell
@property (weak, nonatomic) IBOutlet UITextField *preferenceValue;

- (IBAction)valueChanged:(id)sender;

// setup cell. Title will be displayed in cell's label
- (void) configureCell: (NSString *) identifier withPreferences: (NSUserDefaults *) preferences withTitle: (NSString *) title;

@end

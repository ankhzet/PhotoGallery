//
//  SwitchPreferenceCell.h
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferenceCell.h"

@interface SwitchPreferenceCell : PreferenceCell
@property (weak, nonatomic) IBOutlet UISwitch *preferenceValue;

- (IBAction)valueChanged:(id)sender;
@end

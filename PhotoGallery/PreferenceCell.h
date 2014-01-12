//
//  PreferenceCell.h
//  PhotoGallery
//
//  Created by Ankh on 12.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *preferenceTitle;

@property (nonatomic, weak) NSUserDefaults *preferences;
@property (nonatomic, strong) NSString *preferenceIdentifier;

+ (id) newCell;

- (void) configureCell: (NSString *) identifier withPreferences: (NSUserDefaults *) preferences withTitle: (NSString *) title;
@end

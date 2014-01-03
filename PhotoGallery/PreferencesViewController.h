//
//  PreferencesViewController.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreferencessControllerDelegate <NSObject>

-(void)didDoneWithPreferences:(id)sender;

@end

@interface PreferencesViewController : UITableViewController

@property (nonatomic, weak) id<PreferencessControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneItem;

- (IBAction)actionDone:(id)sender;

@end

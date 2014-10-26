//
//  PreferencesViewController.m
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PreferencesViewController.h"
#import "StringPreferenceCell.h"
#import "SwitchPreferenceCell.h"

@interface PreferencesViewController ()
@property (nonatomic, strong) NSUserDefaults *preferences;
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSArray *sections;

//@property (nonatomic, weak) UITableViewCell *
@end

#define PREF_TYPE 0
#define PREF_UID 1
#define PREF_TITLE 2

__weak static PreferencesViewController *PreferencesViewController_instance;

@implementation PreferencesViewController

+ (instancetype) instance {
	return PreferencesViewController_instance;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.preferences = [NSUserDefaults standardUserDefaults];
	
	NSNumber *prefString = [NSNumber numberWithInt:0];
	NSNumber *prefSwitch = [NSNumber numberWithInt:1];
	
	self.sectionHeaders = @[NSLocalizedString(@"User details", nil), NSLocalizedString(@"iCloud settings", nil)];
	self.sections =
	@[
		@[
			@[prefString, @"userName", NSLocalizedString(@"Name", nil)],
			@[prefString, @"userEmail", NSLocalizedString(@"E-mail", nil)]
			],
		@[
			@[prefSwitch, @"useSynchronization", NSLocalizedString(@"Synchronize via iCloud", nil)],
			@[prefSwitch, @"synkPromptDownload", NSLocalizedString(@"Prompt before up/down-load", nil)]
			]
		];

	PreferencesViewController_instance = self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sectionHeaders[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *section = self.sections[indexPath.section];
	NSArray *preference = section[indexPath.row];
	NSString *identifier = preference[PREF_UID];
	
	PreferenceCell *cell = nil;
	NSNumber *prefType = preference[PREF_TYPE];
	
	switch ([prefType integerValue]) {
		case 0:
			cell = [StringPreferenceCell newCell];
			break;
			
		case 1:
			cell = [SwitchPreferenceCell newCell];
			break;
			
		default:
			NSLog(@"Unknown preference type: %@", prefType);
			return nil;
	}
	
	[cell configureCell:identifier withPreferences:self.preferences withTitle:preference[PREF_TITLE]];
	
	return cell;
}

#pragma mark - Actions

// save preferences before navigating out
- (IBAction)actionDone:(id)sender {
	[self.preferences synchronize];
	[self.delegate didDoneWithPreferences:self];
}

@end

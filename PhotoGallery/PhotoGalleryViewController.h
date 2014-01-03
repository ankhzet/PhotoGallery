//
//  PhotoGalleryViewController.h
//  PhotoGallery
//
//  Created by Ankh on 01.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosTableDataSource.h"

@interface PhotoGalleryViewController : UIViewController

@property (nonatomic, strong) PhotosTableDataSource *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


-(void)reloadTable;
@end

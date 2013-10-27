//
//  PSMasterViewController.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSDetailViewController;

#import <CoreData/CoreData.h>
#import "PSCoreData.h"

@interface PSMasterViewController : UITableViewController <PSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PSDetailViewController *detailViewController;
@property (strong, nonatomic) PSFetchedResultsController *fetchedResultsController;

@end

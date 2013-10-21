//
//  PSFetchedResultsController.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PSFetchedResultsController;

@protocol PSFetchedResultsControllerDelegate <NSObject>

-(void)fetchController:(PSFetchedResultsController*)fetchController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface PSFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate> {
    UITableView* tableView;
    
    __weak id<PSFetchedResultsControllerDelegate> fetchDelegate;
}

-(id)initWithEntityName:(NSString *)entityName
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors;

-(id)initWithEntityName:(NSString *)entityName
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
              predicate:(NSPredicate*)predicate;

-(id)initWithEntityName:(NSString *)entityName
   managedObjectContext:(NSManagedObjectContext *)context
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
              cacheName:(NSString *)name
        sortDescriptors:(NSArray *)sortDescriptors
              predicate:(NSPredicate*)predicate;

@property(strong) UITableView* tableView;
@property(weak) id<PSFetchedResultsControllerDelegate> fetchDelegate;

@end

//
//  PSFetchedResultsController.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "PSFetchedResultsController.h"
#import "PSCoreDataManager.h"

@implementation PSFetchedResultsController

@synthesize tableView, fetchDelegate;

-(id)initWithEntityName:(NSString *)entityName
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors {
    return [self initWithEntityName:entityName
               managedObjectContext:[[PSCoreDataManager sharedInstance] mainContext]
                 sectionNameKeyPath:sectionNameKeyPath
                          cacheName:nil
                    sortDescriptors:sortDescriptors
                          predicate:nil];
}

-(id)initWithEntityName:(NSString *)entityName
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
              predicate:(NSPredicate*)predicate{
    return [self initWithEntityName:entityName
               managedObjectContext:[[PSCoreDataManager sharedInstance] mainContext]
                 sectionNameKeyPath:sectionNameKeyPath
                          cacheName:nil
                    sortDescriptors:sortDescriptors
                          predicate:predicate];
}

-(id)initWithEntityName:(NSString *)entityName
   managedObjectContext:(NSManagedObjectContext *)context
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
              cacheName:(NSString *)name
        sortDescriptors:(NSArray *)sortDescriptors
              predicate:(NSPredicate*)predicate{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if(predicate)
        [fetchRequest setPredicate:predicate];
    
    if (self = [super initWithFetchRequest:fetchRequest
                      managedObjectContext:context
                        sectionNameKeyPath:sectionNameKeyPath
                                 cacheName:name])
    {
        self.delegate = self;
        NSError* error = nil;
        if (![self performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }

    return self;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([self.fetchDelegate respondsToSelector:@selector(fetchController:configureCell:atIndexPath:)]) {
                [self.fetchDelegate fetchController:self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            else
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end

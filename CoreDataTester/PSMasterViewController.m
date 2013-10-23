//
//  PSMasterViewController.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "PSMasterViewController.h"
#import "PSDetailViewController.h"

@interface PSMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PSMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (PSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [[PSCoreDataManager sharedInstance] tempContext];
    [context performBlock:^{
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
        [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        [newManagedObject setValue:[NSNumber numberWithInt:arc4random() % 10] forKey:@"value"];
        
        [[PSCoreDataManager sharedInstance] saveContext:context];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [[PSCoreDataManager sharedInstance] tempContext];
        NSManagedObjectID* objectID = [[self.fetchedResultsController objectAtIndexPath:indexPath] realObjectID];
        [context performBlock:^{
            NSError* error = nil;
            NSManagedObject* obj = [context existingObjectWithID:objectID error:&error];
            if (obj) {
                [context deleteObject:obj];
                [[PSCoreDataManager sharedInstance] saveContext:context];
            }
        }];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [[PSCoreDataManager sharedInstance] tempContext];
    NSManagedObject* object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSManagedObjectID* objectID = [object realObjectID];
    [context performBlock:^{
        NSError* error = nil;
        NSManagedObject* obj = [context existingObjectWithID:objectID error:&error];
        if (obj) {
            [obj setValue:[NSNumber numberWithInt:arc4random() % 10] forKey:@"value"];
            [obj setValue:[NSDate date] forKey:@"timeStamp"];
            [[PSCoreDataManager sharedInstance] saveContext:context];
        }
    }];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo indexTitle];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - PSFetchedResultsControllerDelegate 

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
    _fetchedResultsController
        = [[PSFetchedResultsController alloc] initWithEntityName:@"Event"
                                              sectionNameKeyPath:@"value"
                                                 sortDescriptors:@[sortDescriptor]];
    _fetchedResultsController.tableView = self.tableView;
    _fetchedResultsController.fetchDelegate = self;
    return _fetchedResultsController;
}

-(void)fetchController:(PSFetchedResultsController *)fetchController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString* str = [NSString stringWithFormat:@"%@ - %d", [[[object valueForKey:@"timeStamp"] description] substringToIndex:19], ((NSNumber*)[object valueForKey:@"value"]).intValue];
    cell.textLabel.text = str;
}

@end

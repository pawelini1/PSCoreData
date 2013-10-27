    //
//  PSCoreDataManager.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "PSCoreDataManager.h"

@implementation PSCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize saveManagedObjectContext = _saveManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize storeFilename = _storeFilename;
@synthesize storeModelName = _storeModelName;
@synthesize delegate;

static __strong PSCoreDataManager* instance = nil;

#pragma mark - Core Data Initialization

+(PSCoreDataManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PSCoreDataManager new];
    });
    return instance;
}

+(void)initializeCoreDataManagerWithStoreFilename:(NSString*)_filename
                                     andModelName:(NSString*)_modelName
                                         delegate:(id<PSCoreDataManagerDelegate>)_delegate{
    [[PSCoreDataManager sharedInstance] setStoreFilename:_filename];
    [[PSCoreDataManager sharedInstance] setStoreModelName:_modelName];
    [[PSCoreDataManager sharedInstance] setDelegate:_delegate];
    [[PSCoreDataManager sharedInstance] mainContext];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator 0for the application.

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSManagedObjectContext *context = [self saveManagedObjectContext];
    if (context != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setParentContext:context];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)saveManagedObjectContext
{
    if (_saveManagedObjectContext != nil) {
        return _saveManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _saveManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_saveManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _saveManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.storeModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.storeFilename];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary* options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFailedToMigrateDataAtURL:)])
            [self.delegate manager:self didFailedToMigrateDataAtURL:storeURL];
        else
            [self performDefaultActionWhenMigrationFailedForURL:storeURL];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

-(void)performDefaultActionWhenMigrationFailedForURL:(NSURL*)storeURL{
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
}

#pragma mark - Core Data Saving

- (NSManagedObjectContext *)mainContext
{
    return [self managedObjectContext];
}

- (NSManagedObjectContext *)saveContext
{
    return [self saveManagedObjectContext];
}

- (NSManagedObjectContext *)tempContext
{
    NSManagedObjectContext *retContext = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    if (context != nil) {
        retContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [retContext setParentContext:context];
    }
    return retContext;
}

- (void)saveMainContext{
    [self saveContext:self.managedObjectContext];
}

- (void)saveIOContext{
    [self saveContext:self.saveManagedObjectContext];
}

- (void)saveContext:(NSManagedObjectContext*)ctx
{
    [self saveContext:ctx recursive:YES];
}

- (void)saveContext:(NSManagedObjectContext*)ctx recursive:(BOOL)recursive
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = ctx;
    if (managedObjectContext != nil && [managedObjectContext hasChanges]) {
        if(![managedObjectContext save:&error])
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        else {
            if(recursive && managedObjectContext.parentContext)
                [managedObjectContext.parentContext performBlock:^{
                    if (managedObjectContext.parentContext == self.mainContext) {
                        NSSet* set = managedObjectContext.parentContext.insertedObjects;
                        NSError *error = nil;
                        if(set.count > 0)
                            [managedObjectContext.parentContext obtainPermanentIDsForObjects:[set allObjects] error:&error];
                    }
                    [self saveContext:managedObjectContext.parentContext recursive:recursive];
                }];
        }
    }
}

#pragma mark - Fetching

-(NSArray*)allObjectsForEntityName:(NSString*)entityName usingContext:(NSManagedObjectContext*)ctx{
    return [self allObjectsForEntityName:entityName withPredicate:nil withSortDescriptors:nil usingContext:ctx];
}

-(NSArray*)allObjectsForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate usingContext:(NSManagedObjectContext*)ctx{
    return [self allObjectsForEntityName:entityName withPredicate:predicate withSortDescriptors:nil usingContext:ctx];
}

-(NSArray*)allObjectsForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate withSortDescriptors:(NSArray*)sortDescriptios usingContext:(NSManagedObjectContext*)ctx{
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:ctx];
    if (!entityDescription)
        return nil;
    
    [request setEntity:entityDescription];
    if (predicate)
        [request setPredicate:predicate];
    if(sortDescriptios)
        [request setSortDescriptors:sortDescriptios];
    
    NSError* error = nil;
    NSArray* allObjects = [ctx executeFetchRequest:request error:&error];
    
    return allObjects;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*)bundleDisplayName{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

@end

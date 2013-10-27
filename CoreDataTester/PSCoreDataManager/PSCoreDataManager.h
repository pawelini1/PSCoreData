//
//  PSCoreDataManager.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSCoreDataManager;

@protocol PSCoreDataManagerDelegate <NSObject>

-(void)manager:(PSCoreDataManager*)manager didFailedToMigrateDataAtURL:(NSURL*)storeURL;

@end

@interface PSCoreDataManager : NSObject {
    __weak id<PSCoreDataManagerDelegate> delegate;
}

+(void)initializeCoreDataManagerWithStoreFilename:(NSString*)_filename
                                     andModelName:(NSString*)_modelName
                                         delegate:(id<PSCoreDataManagerDelegate>)_delegate;
+ (PSCoreDataManager*)sharedInstance;
- (void)performDefaultActionWhenMigrationFailedForURL:(NSURL*)storeURL;

- (void)saveContext:(NSManagedObjectContext*)ctx;
- (void)saveContext:(NSManagedObjectContext*)ctx recursive:(BOOL)recursive;
- (void)saveMainContext;
- (void)saveIOContext;
- (NSManagedObjectContext *)tempContext;
- (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext *)saveContext;

- (NSURL *)applicationDocumentsDirectory;

- (NSArray*)allObjectsForEntityName:(NSString*)entityName usingContext:(NSManagedObjectContext*)ctx;
- (NSArray*)allObjectsForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate usingContext:(NSManagedObjectContext*)ctx;
- (NSArray*)allObjectsForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate withSortDescriptors:(NSArray*)sortDescriptios usingContext:(NSManagedObjectContext*)ctx;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *saveManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *storeFilename;
@property (strong, nonatomic) NSString *storeModelName;
@property (weak, nonatomic) id<PSCoreDataManagerDelegate> delegate;

@end

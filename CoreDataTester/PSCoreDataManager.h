//
//  PSCoreDataManager.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCoreDataManager : NSObject {
    
}

+ (void)initializeCoreDataManagerWithStoreFilename:(NSString*)_filename
                                     andModelName:(NSString*)_modelName;
+ (PSCoreDataManager*)sharedInstance;

- (void)saveContext:(NSManagedObjectContext*)ctx;
- (void)saveContext:(NSManagedObjectContext*)ctx recursive:(BOOL)recursive;
- (void)saveMainContext;
- (void)saveIOContext;
- (NSManagedObjectContext *)tempContext;
- (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext *)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *saveManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *storeFilename;
@property (strong, nonatomic) NSString *storeModelName;

@end

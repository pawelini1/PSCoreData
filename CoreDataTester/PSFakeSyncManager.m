//
//  PSFakeSyncManager.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/27/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "PSFakeSyncManager.h"

@implementation PSFakeSyncManager

IMPLEMENT_SINGLETON_FOR_CLASS(PSFakeSyncManager, sharedInstance)

-(id)init{
    if (self = [super init]) {
        //[self performSelector:@selector(simulateDataUpdate) withObject:nil afterDelay:5.0f];
    }
    return self;
}

-(void)simulateDataUpdate{
    NSManagedObjectContext* ctx = [[PSCoreDataManager sharedInstance] tempContext];
    [ctx performBlock:^{
        NSArray* allObjects = [[PSCoreDataManager sharedInstance] allObjectsForEntityName:@"Event" usingContext:ctx];
        for (NSManagedObject* object in allObjects) {
            [object setValue:[NSNumber numberWithInt:arc4random() % 10] forKey:@"value"];
        }
        [[PSCoreDataManager sharedInstance] saveContext:ctx];
    }];
}

@end

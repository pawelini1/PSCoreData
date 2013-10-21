//
//  NSManagedObject+PSCoreData.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/22/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "NSManagedObject+PSCoreData.h"

@implementation NSManagedObject (PSCoreData)

-(NSManagedObjectID*)realObjectID{
    NSManagedObjectID* objectID = [self objectID];
    if (objectID.isTemporaryID) {
        NSError* error = nil;
        [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&error];
        objectID = [self objectID];
        
        if (objectID.isTemporaryID || error != nil)
            return nil;
    }
    return objectID;
}

@end

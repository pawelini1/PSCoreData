//
//  NSManagedObject+PSCoreData.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/22/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "NSManagedObject+PSCoreData.h"
#import <objc/runtime.h>

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

#pragma mark - Changed Keys

-(NSDictionary *)changedKeys{
    return objc_getAssociatedObject(self, @selector(changedKeys));
}

-(void)setChangedKeys:(NSDictionary *)changedKeys{
    objc_setAssociatedObject(self, @selector(changedKeys), changedKeys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)my_didChangeValueForKey:(NSString *)key{
    [self my_didChangeValueForKey:key];
    NSMutableDictionary* _changedKeys = [NSMutableDictionary dictionaryWithDictionary:[self changedKeys]];
    id valueForKey = [self valueForKey:key];
    [_changedKeys setObject:(valueForKey ? valueForKey : [NSNull null]) forKey:key];
    [self setChangedKeys:_changedKeys];
}

-(void)resetChangedKeys{
    [self setChangedKeys:[NSDictionary dictionary]];
}

+(void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(didChangeValueForKey:)),
                                   class_getInstanceMethod(self, @selector(my_didChangeValueForKey:)));
}

@end

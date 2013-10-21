//
//  NSManagedObject+PSCoreData.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/22/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (PSCoreData)

-(NSManagedObjectID*)realObjectID;

@end

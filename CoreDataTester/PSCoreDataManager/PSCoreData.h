//
//  PSCoreData.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/22/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#ifndef PSCoreData_h
#define PSCoreData_h

#import "PSCoreDataManager.h"
#import "PSFetchedResultsController.h"
#import "NSManagedObject+PSCoreData.h"

#define DECLARE_SINGLETON_FOR_CLASS(classname, accessorname) + (classname *)accessorname;

#define IMPLEMENT_SINGLETON_FOR_CLASS(classname, accessorname) \
+ (classname *)accessorname\
{\
static classname *accessorname = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
accessorname = [[classname alloc] init];\
});\
return accessorname;\
}

#endif

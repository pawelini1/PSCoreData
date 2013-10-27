//
//  PSFakeSyncManager.h
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/27/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import "PSCoreData.h"
#import <Foundation/Foundation.h>

@interface PSFakeSyncManager : NSObject

DECLARE_SINGLETON_FOR_CLASS(PSFakeSyncManager, sharedInstance)

- (void)simulateDataUpdate;

@end

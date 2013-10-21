//
//  main.m
//  CoreDataTester
//
//  Created by Paweł Szymański on 10/17/13.
//  Copyright (c) 2013 Paweł Szymański. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PSAppDelegate.h"

int main(int argc, char *argv[])
{
    @try {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([PSAppDelegate class]));
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception userInfo]);
        NSLog(@"%@", [exception callStackSymbols]);
    }
}

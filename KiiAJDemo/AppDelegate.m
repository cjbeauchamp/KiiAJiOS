//
//  AppDelegate.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    do {
        NSLog(@"Listening in the background...  %f", [application backgroundTimeRemaining]);
        [NSThread sleepForTimeInterval:1.0];
    } while ([application backgroundTimeRemaining] > 1.0);
    
    completionHandler(UIBackgroundFetchResultFailed);
}

@end

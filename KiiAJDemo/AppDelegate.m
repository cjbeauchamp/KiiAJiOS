//
//  AppDelegate.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "AppDelegate.h"

#import <KiiSDK/Kii.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [Kii beginWithID:@"a17d7075"
              andKey:@"e77400572e8db7cbd755ea63e06d623e"
             andSite:kiiSiteUS];
    
    NSError *error = nil;
    [KiiUser authenticateSynchronous:@"ipad" withPassword:@"ipad" andError:&error];
    NSLog(@"Error: %@", error);
    
    // Subscribe to a bucket
    [KiiPushSubscription subscribeSynchronous:[Kii bucketWithName:@"messages"] withError:&error];
    NSLog(@"Error: %@", error);
    
    
    // Register APNS
    // If you use Xcode5, you can only use the same code as the else block.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8
        UIUserNotificationSettings* notificationSettings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge |
         UIUserNotificationTypeSound |
         UIUserNotificationTypeAlert
                                          categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        // iOS7 or earlier
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    }

    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [KiiPushInstallation installWithDeviceToken:deviceToken
                             andDevelopmentMode:YES
                                  andCompletion:^(KiiPushInstallation *installation, NSError *error) {
                                      NSLog(@"Push install error: %@", error);
                                  }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Error : Fail Register to APNS. (%@)", error);
}

- (void) application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    
    if([userInfo[@"t"] isEqualToString:@"DATA_OBJECT_CREATED"]) {
        
        NSString *bucket = userInfo[@"bi"];
        

        if([bucket isEqualToString:@"messages"]) {
            
            // add it to our log
            
            // kick it over to the pi
        }
        
    }

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

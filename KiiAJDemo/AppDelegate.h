//
//  AppDelegate.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AJNBusAttachment;
@class DeviceListViewController;
@class AJSVCGenericLoggerDefaultImpl, NotificationViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AJSVCGenericLoggerDefaultImpl *logger;
@property (strong, nonatomic) NSMutableArray *notificationEntries;
@property (strong, nonatomic) NSMutableArray *connectedServices;
@property (strong, nonatomic) NotificationViewController *notificationVC;
@property (strong, nonatomic) DeviceListViewController *deviceVC;
@property (strong, nonatomic) AJNBusAttachment *busAttachment;

+ (AppDelegate*) sharedDelegate;
- (void) sendNotification:(NSString*)message;

@end


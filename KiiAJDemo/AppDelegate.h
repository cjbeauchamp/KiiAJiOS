//
//  AppDelegate.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSFNextControllerConnectionDelegate.h"

#define kLightingControllerFound    @"kii-lighting-controller-found"
#define kNotificationLightEvent     @"kii-lighting-event-posted"
#define kNotificationTrackerUpdate  @"kii-tracker-location-update"

@class LSFLightingDirector;
@class AJNBusAttachment;
@class DeviceListViewController;
@class AJSVCGenericLoggerDefaultImpl, NotificationViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, LSFNextControllerConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AJSVCGenericLoggerDefaultImpl *logger;
@property (strong, nonatomic) NSMutableArray *notificationEntries;
@property (strong, nonatomic) NSMutableArray *connectedServices;
@property (strong, nonatomic) NotificationViewController *notificationVC;
@property (strong, nonatomic) DeviceListViewController *deviceVC;
@property (strong, nonatomic) AJNBusAttachment *busAttachment;
@property (nonatomic, strong) LSFLightingDirector *lightingDirector;

+ (AppDelegate*) sharedDelegate;
- (void) sendNotification:(NSString*)message;

@end


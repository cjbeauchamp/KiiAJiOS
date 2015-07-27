//
//  AppDelegate.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AJSVCGenericLoggerDefaultImpl;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AJSVCGenericLoggerDefaultImpl *logger;

+ (AppDelegate*) sharedDelegate;
- (void) sendNotification:(NSString*)message;

@end


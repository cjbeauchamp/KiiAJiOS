//
//  AppDelegate.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "AppDelegate.h"

#import <KiiSDK/Kii.h>

#import <alljoyn/Status.h>
#import "AJNBus.h"
#import "AJNBusAttachment.h"
#import "alljoyn/services_common/AJSVCGenericLoggerDefaultImpl.h"
#import "ProducerViewController.h"
#import "ConsumerViewController.h"
#import "NotificationUtils.h"


static NSString * const DEFAULT_APP_NAME = @"DISPLAY_ALL";
static NSString * const DAEMON_QUIET_PREFIX = @"quiet@"; // For tcl
static NSString * const DAEMON_NAME = @"org.alljoyn.BusNode.IoeService"; // For tcl

@interface AppDelegate ()

@property (strong, nonatomic) AJNBusAttachment *busAttachment;
@property (strong, nonatomic) AJSVCGenericLoggerDefaultImpl *logger;
@property (strong, nonatomic) ProducerViewController *producerVC;
@property (strong, nonatomic) ConsumerViewController *consumerVC;

@end

@implementation AppDelegate


- (void) setupNotification
{
    QStatus status;
    
    [self.logger debugTag:[[self class] description] text:@"loadNewSession"];
    status = [self loadNewSession];
    if (ER_OK != status) {
        [[[UIAlertView alloc] initWithTitle:@"Startup Error" message:[NSString stringWithFormat:@"%@ (%@)",@"Failed to prepare AJNBusAttachment", [AJNStatus descriptionForStatusCode:status]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    [self.logger debugTag:[[self class] description] text:@"Starting producer...."];
    // Forward shared properties
    self.producerVC.busAttachment = self.busAttachment;
    self.producerVC.logger = self.logger;
    self.producerVC.appName = DEFAULT_APP_NAME;
    // Present view
    [self.producerVC.view setHidden:NO];
    // Set service flag
    
    status = [self.producerVC startProducer];
    if (ER_OK != status) {
        [self.logger debugTag:[[self class] description] text:@"Failed to startProducer"];
    }
    
    
    
    [self.logger debugTag:[[self class] description] text:@"Starting consumer..."];
    // Forward shared properties
    self.consumerVC.busAttachment = self.busAttachment;
    self.consumerVC.logger = self.logger;
    self.consumerVC.appName = DEFAULT_APP_NAME;
    // Present view
    [self.consumerVC.view setHidden:NO];
    // Set service flag
    status = [self.consumerVC startConsumer];
    if (ER_OK != status) {
        [self.logger debugTag:[[self class] description] text:@"Failed to startConsumer"];
        [[[UIAlertView alloc] initWithTitle:@"Startup Error"
                                    message:[NSString stringWithFormat:@"%@ (%@)",@"Failed to startConsumer", [AJNStatus descriptionForStatusCode:status]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }

}


#pragma mark - Util methods
- (QStatus)loadNewSession
{
    QStatus status = ER_OK;
    
    // Set a default logger
    self.logger = [[AJSVCGenericLoggerDefaultImpl alloc] init];
    // Set a bus
    if (!self.busAttachment) {
        status = [self prepareBusAttachment:nil];
        if (ER_OK != status) {
            [self.logger debugTag:@"" text:@"Failed to prepareBusAttachment"];
            return status;
        } else {
            [self.logger debugTag:[[self class] description] text:@"Bus is ready to use"];
        }
    }
    return status;
}

- (void)closeSession
{
    QStatus status;
    [self.logger debugTag:[[self class] description] text:@"Both services are off"];
    // reset the application Text view
    
    // stop bus attachment
    [self.logger debugTag:[[self class] description] text:@"Stopping the bus..."];
    
    if (self.busAttachment) {
        status = [self.busAttachment stop];
        if (status != ER_OK) {
            [self.logger debugTag:[[self class] description] text:@"failed to stop the bus"];
        }
        self.busAttachment = nil;
    }
    
    // destroy logger
    if (self.logger) {
        self.logger = nil;
    }
}

- (QStatus)prepareBusAttachment:(id <AJNAuthenticationListener> )authListener
{
    self.busAttachment = [[AJNBusAttachment alloc] initWithApplicationName:@"CommonServiceApp" allowRemoteMessages:true];
    
    // Start the BusAttachment
    QStatus status = [self.busAttachment start];
    if (status != ER_OK) {
        [self.logger errorTag:[[self class] description] text:@"Failed to start AJNBusAttachment"];
        [self.busAttachment destroy];
        return ER_FAIL;
    }
    
    // Connect to the daemon using address provided
    status = [self.busAttachment connectWithArguments:nil];
    if (status != ER_OK) {
        [self.busAttachment destroy];
        return ER_FAIL;
    }
    
    if (authListener) {
        status = [self.busAttachment enablePeerSecurity:@"ALLJOYN_PIN_KEYX ALLJOYN_SRP_KEYX ALLJOYN_ECDHE_PSK" authenticationListener:authListener];
        if (status != ER_OK) {
            [self.busAttachment destroy];
            return ER_FAIL;
        }
    }
    
    // advertise Daemon
    status = [self.busAttachment requestWellKnownName:DAEMON_NAME withFlags:kAJNBusNameFlagDoNotQueue];
    if (status == ER_OK) {
        //advertise the name with a quite prefix for TC to find it
        status = [self.busAttachment advertiseName:[NSString stringWithFormat:@"%@%@", DAEMON_QUIET_PREFIX, DAEMON_NAME] withTransportMask:kAJNTransportMaskAny];
        if (status != ER_OK) {
            [self.busAttachment releaseWellKnownName:DAEMON_NAME];
            [self.logger errorTag:[[self class] description] text:@"Failed to advertise daemon name"];
        } else {
            [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"Succefully advertised daemon name %@", DAEMON_NAME]];
        }
    }
    return status;
}



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

    [self setupNotification];
    
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

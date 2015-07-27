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
#import "NotificationUtils.h"
#import "alljoyn/notification/AJNSNotificationSender.h"
#import "alljoyn/notification/AJNSNotificationService.h"
#import "samples_common/AJSCCommonBusListener.h"
#import "alljoyn/about/AJNAboutServiceApi.h"
#import "AJNVersion.h"

static NSString * const DEFAULT_APP_NAME = @"DISPLAY_ALL";
static NSString * const DAEMON_QUIET_PREFIX = @"quiet@"; // For tcl
static NSString * const DAEMON_NAME = @"org.alljoyn.BusNode.IoeService"; // For tcl
static NSString * const DEVICE_ID_PRODUCER= @"ProducerBasic";
static NSString * const DEVICE_NAME_PRODUCER= @"ProducerBasic";
static NSString * const DEFAULT_LANG_PRODUCER= @"en";
static NSString * const RICH_ICON_OBJECT_PATH= @"rich/Icon/Object/Path";
static NSString * const RICH_AUDIO_OBJECT_PATH= @"rich/Audio/Object/Path";
static short const SERVICE_PORT= 900;

static const uint16_t TTL_MIN = 30;
static const uint16_t TTL_MAX = 43200;
static NSString *const DEFAULT_TTL = @"40000";
static NSString *const DEFAULT_MSG_TYPE = @"INFO";

@interface AppDelegate ()
<AJNSNotificationReceiver>

@property (strong, nonatomic) AJNBusAttachment *busAttachment;

@property (weak, nonatomic) AJNSNotificationSender *Sender;
@property (strong, nonatomic) AJNSNotificationService *producerService;
@property (strong, nonatomic) AJSCCommonBusListener *commonBusListener;
@property (strong, nonatomic) AJNAboutPropertyStoreImpl *aboutPropertyStoreImpl;

@property (weak, nonatomic) AJNSNotificationService *consumerService;

@property (strong, nonatomic) UIAlertView *selectConsumerLang;
@property (strong, nonatomic) NSMutableArray *notificationEntries; // array of NotificationEntry objects

@property (weak, nonatomic) AJNAboutServiceApi *aboutService;
@property (strong, nonatomic) UIAlertView *selectLanguage;
@property (strong, nonatomic) UIAlertView *selectMessageType;
@property (strong, nonatomic) AJNSNotification *notification;
@property (strong, nonatomic) NSMutableArray *notificationTextArr;
@property (strong, nonatomic) NSMutableDictionary *customAttributesDictionary;
@property (strong, nonatomic) NSMutableArray *richAudioUrlArray;

@property (strong, nonatomic) NSString *defaultTTL; // Hold the default ttl as set in the UI
@property (strong, nonatomic) NSString *defaultMessageType; // Hold the default message type as set in the UI

@property (nonatomic) AJNSNotificationMessageType messageType;
@property (strong, nonatomic) NSString *otherLang;

@end

@implementation AppDelegate

+ (AppDelegate*) sharedDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(QStatus)fillAboutPropertyStoreImplData:(NSString*) appId appName:(NSString*) appName deviceId:(NSString*)deviceId deviceName:(NSString*) deviceName defaultLanguage:(NSString*) defaultLang
{
    QStatus status;
    
    // AppId
    status = [self.aboutPropertyStoreImpl setAppId:appId];
    
    if (status != ER_OK) {
        return status;
    }
    
    // AppName
    status = [self.aboutPropertyStoreImpl setAppName:appName];
    if (status != ER_OK) {
        return status;
    }
    
    // DeviceId
    status = [self.aboutPropertyStoreImpl setDeviceId:deviceId];
    if (status != ER_OK) {
        return status;
    }
    
    // DeviceName
    status = [self.aboutPropertyStoreImpl setDeviceName:deviceName];
    
    if (status != ER_OK) {
        return status;
    }
    
    // SupportedLangs
    NSArray *languages = @[@"en", @"sp", @"fr"];
    status = [self.aboutPropertyStoreImpl setSupportedLangs:languages];
    if (status != ER_OK) {
        return status;
    }
    
    // DefaultLang
    status = [self.aboutPropertyStoreImpl setDefaultLang:defaultLang];
    if (status != ER_OK) {
        return status;
    }
    
    // ModelNumber
    status = [self.aboutPropertyStoreImpl setModelNumber:@"Wxfy388i"];
    if (status != ER_OK) {
        return status;
    }
    
    // DateOfManufacture
    status = [self.aboutPropertyStoreImpl setDateOfManufacture:@"10/1/2199"];
    if (status != ER_OK) {
        return status;
    }
    
    // SoftwareVersion
    status = [self.aboutPropertyStoreImpl setSoftwareVersion:@"12.20.44 build 44454"];
    if (status != ER_OK) {
        return status;
    }
    
    // AjSoftwareVersion
    status = [self.aboutPropertyStoreImpl setAjSoftwareVersion:[AJNVersion versionInformation]];
    if (status != ER_OK) {
        return status;
    }
    
    // HardwareVersion
    status = [self.aboutPropertyStoreImpl setHardwareVersion:@"355.499. b"];
    if (status != ER_OK) {
        return status;
    }
    
    // Description
    status = [self.aboutPropertyStoreImpl setDescription:@"This is an Alljoyn Application" language:@"en"];
    if (status != ER_OK) {
        return status;
    }
    
    status = [self.aboutPropertyStoreImpl setDescription:@"Esta es una Alljoyn aplicación" language:@"sp"];
    if (status != ER_OK) {
        return status;
    }
    
    status = [self.aboutPropertyStoreImpl setDescription:@"C'est une Alljoyn application"  language:@"fr"];
    if (status != ER_OK) {
        return status;
    }
    
    // Manufacturer
    status = [self.aboutPropertyStoreImpl setManufacturer:@"Company" language:@"en"];
    if (status != ER_OK) {
        return status;
    }
    
    status = [self.aboutPropertyStoreImpl setManufacturer:@"Empresa" language:@"sp"];
    if (status != ER_OK) {
        return status;
    }
    
    status = [self.aboutPropertyStoreImpl setManufacturer:@"Entreprise" language:@"fr"];
    if (status != ER_OK) {
        return status;
    }
    
    // SupportedUrl
    status = [self.aboutPropertyStoreImpl setSupportUrl:@"http://www.alljoyn.org"];
    if (status != ER_OK) {
        return status;
    }
    
    return status;
}


-(void)logNotification:(AJNSNotification *)ajnsNotification ttl:(uint16_t)ttl
{
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"Sending message with message type: '%@'",[AJNSNotificationEnums AJNSMessageTypeToString:[ajnsNotification messageType]]]];
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"TTL: %hu", ttl]];
    
    for (AJNSNotificationText *notificationText in self.notificationTextArr) {
        [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"message: '%@'",[notificationText getText]]];
    }
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"richIconUrl: '%@'",[ajnsNotification richIconUrl]]];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    [ajnsNotification richAudioUrl:array];
    
    for (AJNSRichAudioUrl *richAudioURL in array) {
        [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"RichAudioUrl: '%@'",[richAudioURL url]]];
    }
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"richIconObjPath: '%@'",[ajnsNotification richIconObjectPath]]];
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"RichAudioObjPath: '%@'",[ajnsNotification richAudioObjectPath]]];
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"Sending notification message for messageType '%d'",[ajnsNotification messageType]]];
    
}

- (QStatus)startProducer
{    
    // Initialize a AJNSNotificationService object
    self.producerService =  [[AJNSNotificationService alloc] init];
    
    // Set logger (see a logger implementation example in  ConsumerViewController.m)
    [self.producerService setLogLevel:QLEVEL_DEBUG];
    
    // Confirm that bus is valid
    if (!self.busAttachment) {
        [self.logger fatalTag:[[self class] description] text:@"BusAttachment is nil"];
        return ER_FAIL;
    }
    
    // Prepare propertyStore
    [self.logger debugTag:[[self class] description] text:@"preparePropertyStore."];
    self.aboutPropertyStoreImpl = [[AJNAboutPropertyStoreImpl alloc] init];
    
    QStatus status = [self fillAboutPropertyStoreImplData:[[NSUUID UUID] UUIDString]
                                                  appName:DEFAULT_APP_NAME
                                                 deviceId:DEVICE_ID_PRODUCER
                                               deviceName:DEVICE_NAME_PRODUCER
                                          defaultLanguage:DEFAULT_LANG_PRODUCER];
    if (status != ER_OK) {
        [self.logger errorTag:[[self class] description] text:@"Could not fill PropertyStore."];
        return ER_FAIL;
    }
    
    // Prepare AJNSBusListener
    self.commonBusListener = [[AJSCCommonBusListener alloc] init];
    
    // Prepare AboutService
    [self.logger debugTag:[[self class] description] text:@"prepareAboutService"];
    status = [self prepareAboutService:self.commonBusListener servicePort:SERVICE_PORT];
    if (status != ER_OK) {
        [self.logger fatalTag:[[self class] description] text:@"Could not prepareAboutService."];
        return ER_FAIL;
    }
    
    // Call initSend
    self.Sender = [self.producerService startSendWithBus:self.busAttachment andPropertyStore:self.aboutPropertyStoreImpl];
    if (!self.Sender) {
        [self.logger fatalTag:[[self class] description] text:@"Could not initialize Sender"];
        return ER_FAIL;
    }
    
    // Call announce
    status = [self.aboutService announce];
    if (status != ER_OK) {
        [self.logger fatalTag:[[self class] description] text:@"Could not announce"];
        return ER_FAIL;
    } else {
        [self.logger debugTag:[[self class] description] text:@"Announce..."];
    }
    
    return ER_OK;
}

- (void)stopProducer:(bool) isConsumerOn
{
    QStatus status;
    
    [self.logger debugTag:[[self class] description] text:@"Stop Producer service"];
    
    if (self.Sender) {
        self.Sender = nil;
    }
    
    // AboutService destroy
    if (self.aboutService) {
        // AboutService destroyInstance
        [self.aboutService destroyInstance]; //isServiceStarted = false, call [self.aboutService unregister]
        status = [self.busAttachment unbindSessionFromPort:SERVICE_PORT];
        if (status != ER_OK) {
            [self.logger errorTag:[[self class] description] text:@"Failed to unbindSessionFromPort"];
        }
        self.aboutService = nil;
    }
    
    if (self.aboutPropertyStoreImpl) {
        self.aboutPropertyStoreImpl = nil;
    }
    
    // Shutdown producer
    if (self.producerService && isConsumerOn) {
        [self.logger debugTag:[[self class] description] text:@"calling shutdownSender"];
        [self.producerService shutdownSender];
    }
    else {
        [self.logger debugTag:[[self class] description] text:@"calling shutdown"];
        [self.producerService shutdown];
    }
    self.producerService = nil;
    
    // Unregister bus listener from the common
    if (self.busAttachment && self.commonBusListener) {
        [self.busAttachment unregisterBusListener:self.commonBusListener];
        [self.busAttachment unbindSessionFromPort:([self.commonBusListener sessionPort])];
        self.commonBusListener = nil;
    }
}

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
    status = [self startProducer];
    if (ER_OK != status) {
        [self.logger debugTag:[[self class] description] text:@"Failed to startProducer"];
    }
    
    [self.logger debugTag:[[self class] description] text:@"Starting consumer...."];
    status = [self startConsumer];
    if (ER_OK != status) {
        [self.logger debugTag:[[self class] description] text:@"Failed to start consumer"];
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


// Send a notification
- (void) sendNotification
{
    NSString *nsender = @"iosTestApp";
    
    NSString *curr_controlPanelServiceObjectPath = @"";
    
    self.notification = [[AJNSNotification alloc] initWithMessageType:INFO
                                                  andNotificationText:@[[[AJNSNotificationText alloc] initWithLang:@"en" andText:@"Test message"]]];
    
    // This is an exaple of using AJNSNotification setters :
    [self.notification setMessageId:-1];
    [self.notification setDeviceId:nil];
    [self.notification setDeviceName:nil];
    [self.notification setAppId:nil];
    [self.notification setAppName:DEFAULT_APP_NAME];
    [self.notification setSender:nsender];
    [self.notification setCustomAttributes:self.customAttributesDictionary];
//    [self.notification setRichIconUrl:richIconUrl];
//    [self.notification setRichAudioUrl:self.richAudioUrlArray];
//    [self.notification setRichIconObjectPath:RICH_ICON_OBJECT_PATH];
//    [self.notification setRichAudioObjectPath:RICH_AUDIO_OBJECT_PATH];
    [self.notification setControlPanelServiceObjectPath:curr_controlPanelServiceObjectPath];
    
    
    [self logNotification:self.notification ttl:TTL_MIN];
    
    [self.richAudioUrlArray removeAllObjects];
    
    // Call send
    QStatus sendStatus = [self.Sender send:self.notification ttl:TTL_MIN];
    if (sendStatus != ER_OK) {
        [self.logger infoTag:[[self class] description] text:[NSString stringWithFormat:@"Send has failed"]];
    }
    else {
        [self.logger infoTag:[[self class] description] text:[NSString stringWithFormat:@"Successfully sent!"]];
    }

}

#pragma mark - About Service methods

- (QStatus)prepareAboutService:(AJSCCommonBusListener *)busListener servicePort:(AJNSessionPort)port
{
    if (!self.busAttachment)
        return ER_BAD_ARG_1;
    
    if (!busListener)
        return ER_BAD_ARG_2;
    
    if (!self.aboutPropertyStoreImpl)
    {
        [self.logger errorTag:[[self class] description] text:@"PropertyStore is empty"];
        return ER_FAIL;
    }
    
    // Prepare About Service
    self.aboutService = [AJNAboutServiceApi sharedInstance];
    
    if (!self.aboutService)
    {
        return ER_BUS_NOT_ALLOWED;
    }
    
    [self.aboutService startWithBus:self.busAttachment andPropertyStore:self.aboutPropertyStoreImpl]; //isServiceStarted = true
    
    
    
    [self.logger debugTag:[[self class] description] text:@"registerBusListener"];
    [busListener setSessionPort:port];
    [self.busAttachment registerBusListener:busListener];
    
    AJNSessionOptions *opt = [[AJNSessionOptions alloc] initWithTrafficType:(kAJNTrafficMessages) supportsMultipoint:(false) proximity:(kAJNProximityAny) transportMask:(kAJNTransportMaskAny)];
    QStatus aboutStatus = [self.busAttachment bindSessionOnPort:SERVICE_PORT withOptions:opt withDelegate:busListener];
    
    if (aboutStatus == ER_ALLJOYN_BINDSESSIONPORT_REPLY_ALREADY_EXISTS)
        [self.logger infoTag:[[self class] description] text:([NSString stringWithFormat:@"bind status: ER_ALLJOYN_BINDSESSIONPORT_REPLY_ALREADY_EXISTS"])];
    if (aboutStatus != ER_OK)
        return aboutStatus;
    return [self.aboutService registerPort:(SERVICE_PORT)];
}

- (IBAction)selectLanguagePressed:(UIButton *)sender
{
    [self showSelectLanguageAlert];
}

- (IBAction)selectMessageTypePressed:(UIButton *)sender
{
    [self showMessageTypeAlert];
}

- (void)showSelectLanguageAlert
{
    NSArray *langArray = [[NSMutableArray alloc] initWithObjects:@"English", @"Hebrew", @"Russian", nil];
    
    self.selectLanguage = [[UIAlertView alloc] initWithTitle:@"Select Language" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    for (NSString *str in langArray) {
        [self.selectLanguage addButtonWithTitle:str];
    }
    
    [self.selectLanguage show];
}

- (void)showMessageTypeAlert
{
    NSArray *messageTypeArray = [[NSMutableArray alloc] initWithObjects:@"INFO", @"WARNING", @"EMERGENCY", nil];
    
    self.selectMessageType = [[UIAlertView alloc] initWithTitle:@"Select Language" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    for (NSString *str in messageTypeArray) {
        [self.selectMessageType addButtonWithTitle:str];
    }
    
    [self.selectMessageType show];
}

#pragma mark - Application util methods

- (NSString *)convertToLangCode:(NSString *)value
{
    if ([value isEqualToString:@"English"]) {
        return @"en";
    }
    else if ([value isEqualToString:@"Hebrew"]) {
        return @"he";
    }
    else if ([value isEqualToString:@"Russian"]) {
        return @"ru";
    }
    return nil;
}


- (QStatus)startConsumer
{
    QStatus status;
    
    // Initialize Service object and send it Notification Receiver object
    self.consumerService = [AJNSNotificationService sharedInstance];
    
    /*   This is an example of using the AJNSNotificationService default Logger (QSCGenericLoggerDefaultImpl)
     
     // Get the default logger
     [self.consumerService logger];
     
     // Get the default logger log level
     [self.consumerService logLevel]
     
     // Set a new logger level
     [self.consumerService setLogLevel:QLEVEL_WARN];
     
     // Print the new log level
     //    NSString *newLogLevel = [NSString stringWithFormat:@"Consumer Logger has started in %@ mode", [AJSVCGenericLoggerUtil toStringQLogLevel:[self.consumerService logLevel]]];
     //    [[self.consumerService logger] debugTag:[[self class] description] text: newLogLevel];
     
     // Instead, you can use a self implementation logger as shown below:
     */
    [self.consumerService setLogLevel:QLEVEL_DEBUG];
    
    if (!self.busAttachment) {
        [self.logger fatalTag:[[self class] description] text:@"BusAttachment is nil"];
        return ER_FAIL;
    }
    
    // Call "initReceive"
    status = [self.consumerService startReceive:self.busAttachment withReceiver:self];
    if (status != ER_OK) {
        [self.logger fatalTag:[[self class] description] text:@"Could not initialize receiver"];
        return ER_FAIL;
    }
    
    // Set Consumer UI
    [self.logger debugTag:[[self class] description] text:@"Waiting for notifications"];
    return ER_OK;
}

- (void)stopConsumer:(bool) isProducerOn
{
    [self.logger debugTag:[[self class] description] text:@"Stop Consumer service"];
    
    if (self.consumerService && isProducerOn) {
        [self.consumerService shutdownReceiver];
        [self.logger debugTag:[[self class] description] text:@"calling shutdownReceiver"];
    } else {
        [self.consumerService shutdown];
        [self.logger debugTag:[[self class] description] text:@"calling shutdown"];
    }
    self.consumerService = nil;
    
    [self.notificationEntries removeAllObjects];
}

-(void)logNotification:(AJNSNotification *)ajnsNotification
{
    NSMutableString *notificationContent = [[NSMutableString alloc] init];
    
    [notificationContent appendFormat:@"Application name: %@\n[current app name is %@]\n", [ajnsNotification appName], DEFAULT_APP_NAME];
    
    [notificationContent appendFormat:@"Message id: '%d'\n",[ajnsNotification messageId]];
    
    [notificationContent appendFormat:@"MessageType: '%@'\n",[AJNSNotificationEnums AJNSMessageTypeToString:[ajnsNotification messageType]]];
    
    [notificationContent appendFormat:@"Device id: '%@'\n",[ajnsNotification deviceId]];
    
    [notificationContent appendFormat:@"Device Name: '%@'\n",[ajnsNotification deviceName]];
    
    [notificationContent appendFormat:@"Sender: '%@'\n",[ajnsNotification senderBusName]];
    
    [notificationContent appendFormat:@"AppId: '%@'\n",[ajnsNotification appId]];
    
    //    [notificationContent appendFormat:@"CustomAttributes: '%@'\n",[ajnsNotification.customAttributes description]];
    
    [notificationContent appendFormat:@"richIconUrl: '%@'\n",[ajnsNotification richIconUrl]];
    
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [ajnsNotification richAudioUrl:array];
    
    if ([array count]) {
        [notificationContent appendString:@"RichAudioUrl: "];
        for (AJNSRichAudioUrl *richAudioURL in array) {
            [notificationContent appendFormat:@"'%@'",[richAudioURL url]];
        }
        [notificationContent appendString:@"\n"];
    } else {
        [notificationContent appendFormat:@"RichAudioUrl is empty\n"];
    }
    
    [notificationContent appendFormat:@"richIconObjPath: '%@'\n",[ajnsNotification richIconObjectPath]];
    
    [notificationContent appendFormat:@"RichAudioObjPath: '%@'\n",[ajnsNotification richAudioObjectPath]];
    
    [notificationContent appendFormat:@"CPS Path: '%@'\n",[ajnsNotification controlPanelServiceObjectPath]];
    
    
    AJNSNotificationText *nt = ajnsNotification.ajnsntArr[0];
    
    [notificationContent appendFormat:@"First msg: '%@' [total: %lu]\n", [nt getText], (unsigned long)[ajnsNotification.ajnsntArr count]];
    
    [notificationContent appendFormat:@"Received message Lang: '%@'\n",[nt getLanguage]];
    
    [self.logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"Received new Notification:\n%@", notificationContent]];
    
}

#pragma mark - AJNSNotificationReceiver protocol methods

- (void)dismissMsgId:(const int32_t)msgId appId:(NSString*) appId
{
    NSLog(@"Dismiss msg id");
}

// Parse AJNSNotification into a string
- (void)receive:(AJNSNotification *)ajnsNotification
{
    [self logNotification:ajnsNotification];
}

@end

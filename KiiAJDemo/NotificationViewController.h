//
//  NotificationViewController.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJNBusAttachment.h"
#import "alljoyn/services_common/AJSVCGenericLoggerDefaultImpl.h"

@interface NotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *notificationEnTextField;
@property (weak, nonatomic) IBOutlet UITextField *notificationLangTextField;
@property (weak, nonatomic) IBOutlet UITextField *ttlTextField;
@property (weak, nonatomic) IBOutlet UITextField *audioTextField;
@property (weak, nonatomic) IBOutlet UITextField *iconTextField;

@property (weak, nonatomic) IBOutlet UILabel *defaultLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *ttlLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTypeLabel;

@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *iconSwitch;

@property (weak, nonatomic) IBOutlet UIButton *messageTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *sendNotificationButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *langButton;

// Shared properties
@property (strong, nonatomic) AJNBusAttachment *busAttachment;
@property (strong, nonatomic) AJSVCGenericLoggerDefaultImpl *logger;
@property (strong, nonatomic) NSString *appName;

- (IBAction)didTouchSendNotificationButton:(id)sender;

- (IBAction)didChangeAudioSwitchValue:(id)sender;

- (IBAction)didChangeIconSwitchValue:(id)sender;

- (IBAction)didTouchDeleteButton:(id)sender;

- (QStatus)startProducer;

- (void)stopProducer:(bool) isConsumerOn;

@end

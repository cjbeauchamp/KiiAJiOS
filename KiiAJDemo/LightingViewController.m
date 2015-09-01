//
//  LightingViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 8/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "LightingViewController.h"

#import "LSFLightingDirector.h"
#import "LSFLamp.h"
#import "LSFGroup.h"
#import "LSFLightingScene.h"

#import "AppDelegate.h"

#import <KiiSDK/Kii.h>

#define LAMP_ID @"5f2e28c8e30b6aaef5613feaaa871d45"

@interface LightingViewController ()

@end

@implementation LightingViewController

- (void) controllerEnabled
{
    
}

- (void) updateStatus:(NSString*)method withValue:(NSNumber*)value
{
    // pull down the light object
    KiiObject *obj = [KiiObject objectWithURI:@"kiicloud://buckets/device_status/objects/2b8c7750-5080-11e5-a170-22000af941bb"];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        
        // update our values
        [object setObject:value forKey:method];
        
        // save
        [object saveWithBlock:^(KiiObject *object, NSError *error) {
            NSLog(@"Saved status: %@", error);
        }];
        
    }];
}

- (void) methodCalled:(NSNotification*)notification
{
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    NSDictionary *userInfo = [notification userInfo];
    
    for (LSFLamp *lamp in lamps) {
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            if([userInfo[@"method"] isEqualToString:@"power"]) {
                if([userInfo[@"value"] boolValue]) {
                    [lamp turnOn];
                    [self updateStatus:@"power" withValue:@TRUE];
                } else {
                    [lamp turnOff];
                    [self updateStatus:@"power" withValue:FALSE];
                }
            } else if([userInfo[@"method"] isEqualToString:@"flash"]) {
                [lamp turnOn];
                [self flash:nil];
                [self updateStatus:@"power" withValue:@TRUE];
            } else if([userInfo[@"method"] isEqualToString:@"brightness"]) {
                [lamp turnOn];
                [lamp setColorWithHue:360 saturation:100 brightness:[userInfo[@"value"] intValue] andColorTemp:9000];
                [self updateStatus:@"power" withValue:@TRUE];
                [self updateStatus:@"brightness" withValue:userInfo[@"value"]];
            }
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerEnabled)
                                                 name:kLightingControllerFound
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(methodCalled:)
                                                 name:kNotificationLightEvent
                                               object:nil];

}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLightingControllerFound object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)turnOff:(id)sender {
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {
        
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            [lamp turnOff];
            [self updateStatus:@"power" withValue:@FALSE];
        }
    }
}

- (IBAction)turnOn:(id)sender {
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {

        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            [lamp turnOn];
            [self updateStatus:@"power" withValue:@TRUE];
        }
    }
}

- (IBAction)flash:(id)sender {
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];

        if([details.lampID isEqualToString:LAMP_ID]) {

            [lamp turnOn];
            [lamp setColorWithHue:360 saturation:100 brightness:0 andColorTemp:9000];

            for(NSUInteger i=0; i<5; i++) {
                [lamp setColorWithHue:360 saturation:100 brightness:100 andColorTemp:9000];
                [NSThread sleepForTimeInterval:1];
                [lamp setColorWithHue:360 saturation:100 brightness:50 andColorTemp:9000];
                [NSThread sleepForTimeInterval:1];
            }

            [lamp setColorWithHue:360 saturation:100 brightness:100 andColorTemp:9000];
            [self updateStatus:@"power" withValue:@TRUE];
            [self updateStatus:@"brightness" withValue:@100];
        }
    }
}

@end

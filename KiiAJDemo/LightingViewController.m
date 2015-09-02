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

#define LAMP_ID @"c7cfda66973461e05c502b94ad08498e"
#define DEFAULT_COLOR_TEMP      9000
#define DEFAULT_BRIGHTNESS      100
#define FLASH_OFF_BRIGHTNESS    50

#define MIN_DISTANCE    25

@interface LightingViewController ()

@end

static CLLocation *_schoolLocation = [[CLLocation alloc] initWithLatitude:37.43828 longitude:-122.15096];
static CLLocation *_homeLocation = [[CLLocation alloc] initWithLatitude:37.43146 longitude:-122.14886];

@implementation LightingViewController

- (void) controllerEnabled
{
    
}

- (void) updateStatus:(NSDictionary*)values
{
    // pull down the light object
    KiiObject *obj = [KiiObject objectWithURI:@"kiicloud://buckets/device_status/objects/2b8c7750-5080-11e5-a170-22000af941bb"];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        
        // update our values
        for(NSString *key in [values allKeys]) {
            [object setObject:[values objectForKey:key] forKey:key];
        }
        
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
                    [self turnOn:nil];
                } else {
                    [self turnOff:nil];
                }
            } else if([userInfo[@"method"] isEqualToString:@"flash"]) {
                
                self.lightPower.on = TRUE;
                [lamp turnOn];
                [self flash:nil];
                [self updateStatus:@{@"power":@TRUE}];
                
            } else if([userInfo[@"method"] isEqualToString:@"brightness"]) {
                [lamp turnOn];
                [lamp setColorWithHue:360
                           saturation:100
                           brightness:[userInfo[@"value"] intValue]
                         andColorTemp:self.lightTemp.value];
                
                [self updateStatus:@{@"power": @TRUE, @"brightness": userInfo[@"value"]}];

                self.lightPower.on = TRUE;
                self.lightBrightness.value = [userInfo[@"value"] floatValue];
                self.lightTemp.value = DEFAULT_COLOR_TEMP;
            
            } else if([userInfo[@"method"] isEqualToString:@"colorTemp"]) {
                [lamp turnOn];
                
                [lamp setColorWithHue:360
                           saturation:100
                           brightness:self.lightBrightness.value
                         andColorTemp:[userInfo[@"value"] intValue]];
                
                [self updateStatus:@{
                                     @"power": @TRUE,
                                     @"brightness": [NSNumber numberWithInt:DEFAULT_BRIGHTNESS],
                                     @"colorTemp": userInfo[@"value"]
                                     }];
                
                self.lightPower.on = TRUE;
                self.lightBrightness.value = DEFAULT_BRIGHTNESS;
                self.lightTemp.value = [userInfo[@"value"] floatValue];

            }
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(37.434833, -122.150335);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    [self.mapView setDelegate:self];
    
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:_schoolLocation.coordinate radius:25]];
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:_homeLocation.coordinate radius:25]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocation:)
                                                 name:kNotificationTrackerUpdate
                                               object:nil];

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
        NSLog(@"LAMPID: %@", details.lampID);
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            [lamp turnOff];
            self.lightPower.on = FALSE;
            [self updateStatus:@{@"power":@FALSE}];
        }
    }
}

- (IBAction)turnOn:(id)sender {
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        NSLog(@"Lamp id: %@", details.lampID);
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            [lamp turnOn];
            self.lightPower.on = TRUE;
            self.lightBrightness.value = DEFAULT_BRIGHTNESS;
            self.lightTemp.value = DEFAULT_COLOR_TEMP;

            [lamp setColorWithHue:360 saturation:100 brightness:DEFAULT_BRIGHTNESS andColorTemp:DEFAULT_COLOR_TEMP];
            [self updateStatus:@{
                                 @"brightness":[NSNumber numberWithInt:DEFAULT_BRIGHTNESS],
                                 @"colorTemp":[NSNumber numberWithInt:DEFAULT_COLOR_TEMP],
                                 @"power":@TRUE
                                 }];
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
            self.lightPower.on = TRUE;
            [lamp setColorWithHue:360 saturation:100 brightness:0 andColorTemp:DEFAULT_COLOR_TEMP];

            for(NSUInteger i=0; i<5; i++) {
                [lamp setColorWithHue:360 saturation:100 brightness:DEFAULT_BRIGHTNESS andColorTemp:DEFAULT_COLOR_TEMP];
                [NSThread sleepForTimeInterval:0.6];
                [lamp setColorWithHue:360 saturation:100 brightness:FLASH_OFF_BRIGHTNESS andColorTemp:DEFAULT_COLOR_TEMP];
                [NSThread sleepForTimeInterval:0.6];
            }

            [lamp setColorWithHue:360
                       saturation:100
                       brightness:self.lightBrightness.value
                     andColorTemp:self.lightTemp.value];
            
            [self updateStatus:@{
                                 @"power":@TRUE,
                                 @"brightness":[NSNumber numberWithInt:self.lightBrightness.value],
                                 @"colorTemp":[NSNumber numberWithInt:self.lightTemp.value]
                                 }];
            
        }
    }
}

- (IBAction)lightPowerChanged:(id)sender {
    
    if(self.lightPower.isOn) {
        [self turnOn:sender];
    } else {
        [self turnOff:sender];
    }
}

- (IBAction)lightBrightnessChanged:(id)sender {
    
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        
        if([details.lampID isEqualToString:LAMP_ID]) {

            [lamp turnOn];
            [lamp setColorWithHue:360
                       saturation:100
                       brightness:self.lightBrightness.value
                     andColorTemp:self.lightTemp.value];
            
            [self updateStatus:@{@"power": @TRUE,
                                 @"brightness": [NSNumber numberWithFloat:self.lightBrightness.value]}];
            
            self.lightPower.on = TRUE;
            
        }
    }
}

- (IBAction)lightTempChanged:(id)sender {
    
    NSArray *lamps = [[AppDelegate sharedDelegate].lightingDirector getLamps];
    
    for (LSFLamp *lamp in lamps)
    {
        LSFLampModel *data = [lamp getLampDataModel];
        LSFLampDetails *details = [data lampDetails];
        
        if([details.lampID isEqualToString:LAMP_ID]) {
            
            [lamp turnOn];
            [lamp setColorWithHue:360
                       saturation:100
                       brightness:self.lightBrightness.value
                     andColorTemp:self.lightTemp.value];
            
            [self updateStatus:@{@"power": @TRUE,
                                 @"colorTemp": [NSNumber numberWithFloat:self.lightTemp.value]}];
            
            self.lightPower.on = TRUE;
            
        }
    }
}

- (void) updateLocation:(NSNotification*)notification
{
    NSDictionary *vals = notification.userInfo;
    
    CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"tracker-latitude"]
                                                         longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"tracker-longitude"]];
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:[vals[@"latitude"] doubleValue]
                                                         longitude:[vals[@"longitude"] doubleValue]];
    
    CLLocationDistance oldDistanceFromSchool = [oldLocation distanceFromLocation:_schoolLocation];
    CLLocationDistance newDistanceFromSchool = [newLocation distanceFromLocation:_schoolLocation];
    
    CLLocationDistance oldDistanceFromHome = [oldLocation distanceFromLocation:_homeLocation];
    CLLocationDistance newDistanceFromHome = [newLocation distanceFromLocation:_homeLocation];
    
    // store our latest location
    [[NSUserDefaults standardUserDefaults] setDouble:[vals[@"latitude"] doubleValue] forKey:@"tracker-latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:[vals[@"longitude"] doubleValue] forKey:@"tracker-longitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // show the location on the map
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([vals[@"latitude"] doubleValue], [vals[@"longitude"] doubleValue]);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:@"Current Location"];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:annotation];
    
    // trigger any lighting events / notifications
    
    // tracker is now less than 100 meters from home
    if(oldDistanceFromHome > MIN_DISTANCE && newDistanceFromHome < MIN_DISTANCE) {
        // turn on the lights
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightEvent
        //                                                            object:nil
        //                                                          userInfo:@{ @"method":@"power", @"value":@1 }];

        // send a notification
        [[AppDelegate sharedDelegate] sendNotification:@"Timmy has arrived at home"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightEvent
                                                            object:nil
                                                          userInfo:@{ @"method":@"flash" }];
        
        
    } else if(oldDistanceFromSchool > MIN_DISTANCE && newDistanceFromSchool < MIN_DISTANCE) {
        
        // send a notification
        [[AppDelegate sharedDelegate] sendNotification:@"Timmy has arrived at school"];
        
        // flash the lights
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightEvent
                                                            object:nil
                                                          userInfo:@{ @"method":@"flash" }];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircle *circle = (MKCircle*)overlay;
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:circle];
        circleRenderer.fillColor = (circle.coordinate.latitude == _schoolLocation.coordinate.latitude) ?[UIColor colorWithRed:0 green:0 blue:0.8f alpha:1.f] : [UIColor colorWithRed:0 green:0.8f blue:0 alpha:1.f];
        circleRenderer.alpha = 0.5f;
        return circleRenderer;
    }
    
    return nil;
}

@end

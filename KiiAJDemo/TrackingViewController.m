//
//  TrackingViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 8/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "TrackingViewController.h"

#import "AppDelegate.h"

#define MIN_DISTANCE    25

@interface TrackingViewController ()
<MKMapViewDelegate>

@end

static CLLocation *_schoolLocation = [[CLLocation alloc] initWithLatitude:37.43828 longitude:-122.15096];
static CLLocation *_homeLocation = [[CLLocation alloc] initWithLatitude:37.43146 longitude:-122.14886];


@implementation TrackingViewController

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

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightEvent
                                                            object:nil
                                                          userInfo:@{ @"method":@"flash" }];

        // send a notification
        [[AppDelegate sharedDelegate] sendNotification:@"Timmy has arrived at home"];

    } else if(oldDistanceFromSchool > MIN_DISTANCE && newDistanceFromSchool < MIN_DISTANCE) {

        // flash the lights
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightEvent
                                                            object:nil
                                                          userInfo:@{ @"method":@"flash" }];

        // send a notification
        [[AppDelegate sharedDelegate] sendNotification:@"Timmy has arrived at school"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  LightingViewController.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 8/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LightingViewController : UIViewController
<MKMapViewDelegate>

- (IBAction)flash:(id)sender;
- (IBAction)lightPowerChanged:(id)sender;
- (IBAction)lightBrightnessChanged:(id)sender;
- (IBAction)lightTempChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *lightPower;
@property (weak, nonatomic) IBOutlet UISlider *lightBrightness;
@property (weak, nonatomic) IBOutlet UISlider *lightTemp;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
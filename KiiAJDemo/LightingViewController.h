//
//  LightingViewController.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 8/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightingViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (IBAction)turnOff:(id)sender;
- (IBAction)turnOn:(id)sender;
- (IBAction)flash:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
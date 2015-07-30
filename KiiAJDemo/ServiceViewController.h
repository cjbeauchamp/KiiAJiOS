//
//  ServiceViewController.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectedService;
@interface ServiceViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ConnectedService *service;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

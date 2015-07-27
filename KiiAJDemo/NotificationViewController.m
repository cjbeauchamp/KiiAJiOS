//
//  NotificationViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "NotificationViewController.h"

#import "AppDelegate.h"

@interface NotificationViewController()
<UITextFieldDelegate>

@end

@implementation NotificationViewController

- (IBAction) sendNotification:(id)sender
{
    [[AppDelegate sharedDelegate] sendNotification:@"Message from iPad"];
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end

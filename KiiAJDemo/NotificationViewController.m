//
//  NotificationViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/27/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "NotificationViewController.h"

#import "AppDelegate.h"
#import "alljoyn/notification/AJNSNotification.h"

@interface NotificationViewController()
<UITextFieldDelegate>

@end

@implementation NotificationViewController

- (void) refreshTable
{
    [self.tableView reloadData];
    
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate sharedDelegate].notificationVC = self;
}

- (IBAction) sendNotification:(id)sender
{
    [[AppDelegate sharedDelegate] sendNotification:@"Message from iPad"];
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppDelegate sharedDelegate].notificationEntries.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    AJNSNotification *message = [[AppDelegate sharedDelegate].notificationEntries objectAtIndex:indexPath.row];
    
    if([[message text] count] > 0) {
        AJNSNotificationText *text = [[message text] firstObject];
        cell.textLabel.text = [text getText];
    } else {
        cell.textLabel.text = @"<no text>";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [message senderBusName], [message deviceName]];
    
    return cell;
}

@end

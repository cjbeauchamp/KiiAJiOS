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
<UITextFieldDelegate, UIAlertViewDelegate>

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex) {
        NSString *message = [[alertView textFieldAtIndex:0] text];
        [[AppDelegate sharedDelegate] sendNotification:message];
    }
}

- (IBAction)composeAlert:(id)sender
{
    UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"Send Notification"
                                                               message:@"Send a notification across the AllSeen network"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Send",nil];
    alertViewChangeName.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertViewChangeName show];
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

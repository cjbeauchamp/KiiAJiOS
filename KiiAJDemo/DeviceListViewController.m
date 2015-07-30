//
//  DeviceListViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "DeviceListViewController.h"
#import "AppDelegate.h"
#import "ConnectedService.h"
#import "ServiceViewController.h"

@interface DeviceListViewController ()

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(reloadDevices) userInfo:nil repeats:TRUE];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadDevices
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [AppDelegate sharedDelegate].connectedServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ConnectedService *c = [[AppDelegate sharedDelegate].connectedServices objectAtIndex:indexPath.row];
    cell.textLabel.text = c.deviceName;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectedService *c = [[AppDelegate sharedDelegate].connectedServices objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"show_service" sender:c];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ServiceViewController *vc = (ServiceViewController*)segue.destinationViewController;
    vc.service = (ConnectedService*)sender;
}

@end

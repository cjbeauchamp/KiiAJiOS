//
//  ServiceViewController.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "ServiceViewController.h"
#import "AJNBusAttachment.h"
#import "AJNBusInterface.h"
#import "AJNProxyBusObject.h"
#import "AppDelegate.h"
#import "ConnectedService.h"
#import "InterfaceObject.h"
#import "InterfaceMethod.h"
#import "InterfaceArgument.h"
#import "NSString+StripTags.h"
#import "ServicePathObject.h"

#import "XMLDictionary.h"

#import <KiiSDK/Kii.h>

@interface ServiceViewController ()
<AJNSessionListener, AJNProxyBusObjectDelegate>

@property (nonatomic, strong) AJNMessage *methodReply;
@property (nonatomic, strong) AJNProxyBusObject *basicObjectProxy;
@property (nonatomic, assign) AJNSessionId sessionID;
@property (nonatomic, strong) AJNProxyBusObject *proxy;

@property (nonatomic, strong) NSMutableArray *cellObjects;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellObjects = [[NSMutableArray alloc] init];
    
    for(ServicePathObject *o in self.service.pathObjects) {
        [self.cellObjects addObject:o];

        for(InterfaceObject *i in o.interfaces) {
            [self.cellObjects addObject:i];
            
            [self.cellObjects addObjectsFromArray:i.methods];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[AppDelegate sharedDelegate].busAttachment leaveJoinedSession:self.sessionID];
}

- (void)sessionWasLost:(AJNSessionId)sessionId
{
    
}

- (void)sessionWasLost:(AJNSessionId)sessionId forReason:(AJNSessionLostReason)reason
{
    
}

- (void)didAddMemberNamed:(NSString *)memberName toSession:(AJNSessionId)sessionId
{
    
}

- (void)didRemoveMemberNamed:(NSString *)memberName fromSession:(AJNSessionId)sessionId
{
    
}

- (void)didCompleteIntrospectionOfObject:(AJNProxyBusObject *)object
                                 context:(AJNHandle)context
                              withStatus:(QStatus)status
{
    
}

- (void)didReceiveMethodReply:(AJNMessage *)replyMessage context:(AJNHandle)context
{
    NSLog(@"Replymessage: %@", replyMessage);
    for(AJNMessageArgument *arg in [replyMessage arguments]) {
        NSLog(@"AXML => %@", [arg xml]);
    }
}

- (void)didReceiveValueForProperty:(AJNMessageArgument *)value ofObject:(AJNProxyBusObject *)object completionStatus:(QStatus)status context:(AJNHandle)context
{
    
}

- (void)didReceiveValuesForAllProperties:(AJNMessageArgument *)values ofObject:(AJNProxyBusObject *)object completionStatus:(QStatus)status context:(AJNHandle)context
{
    
}

- (void)didComleteSetPropertyOnObject:(AJNProxyBusObject *)object completionStatus:(QStatus)status context:(AJNHandle)context
{
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSString *text = @"______";
    
    id obj = [self.cellObjects objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[ServicePathObject class]]) {
        text = [NSString stringWithFormat:@"P:%@", [(ServicePathObject*)obj name]];
    } else if([obj isKindOfClass:[InterfaceObject class]]) {
        text = [NSString stringWithFormat:@"    IO => %@", [(InterfaceObject*)obj name]];
    } else if([obj isKindOfClass:[InterfaceMethod class]]) {
        text = [NSString stringWithFormat:@"        IM => %@", [(InterfaceMethod*)obj name]];
    }

    // Configure the cell...
    cell.textLabel.text = text;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.cellObjects objectAtIndex:indexPath.row];
    
    if([obj isKindOfClass:[InterfaceMethod class]]) {
        
        InterfaceMethod *m = (InterfaceMethod*)obj;
        
        AJNMessage *mr = [[AJNMessage alloc] init];
        QStatus status = [self.proxy callMethodWithName:m.name
                                    onInterfaceWithName:m.interfaceName
                                          withArguments:nil
                                            methodReply:&mr];
        
        self.methodReply = mr;
        
        if(ER_OK == status) {
            NSLog(@"Worked!");
        } else {
            NSLog(@"Failed!");
        }
    }
}



@end

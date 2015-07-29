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

@interface ServiceViewController ()
<AJNSessionListener, AJNProxyBusObjectDelegate>

@property (nonatomic, strong) AJNProxyBusObject *basicObjectProxy;
@property (nonatomic, assign) AJNSessionId sessionID;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *serviceName = self.service.busName;
    
    
    AJNSessionOptions *opts = [[AJNSessionOptions alloc] initWithTrafficType:kAJNTrafficMessages
                                                          supportsMultipoint:YES
                                                                   proximity:kAJNProximityAny
                                                               transportMask:kAJNTransportMaskAny];
    
    self.sessionID = [[AppDelegate sharedDelegate].busAttachment joinSessionWithName:serviceName
                                                                                      onPort:900
                                                                                withDelegate:self
                                                                                     options:opts];

    NSLog(@"Session id: %du", self.sessionID);
    
    AJNProxyBusObject *proxy = [[AJNProxyBusObject alloc] initWithBusAttachment:[AppDelegate sharedDelegate].busAttachment
                                                                    serviceName:serviceName
                                                                     objectPath:@"/"
                                                                      sessionId:self.sessionID];
    
    
    // get a description of the interfaces implemented by the remote object before making the call
    //
    QStatus err = [proxy introspectRemoteObject];
    if(err == ER_OK) {
        NSLog(@"Got introspection");
        NSLog(@"Interfaces: %@", [proxy interfaces]);
        
        for(AJNInterfaceDescription *d in [proxy interfaces]) {
            NSLog(@"XML => %@", [d xmlDescription]);
        }
        
    } else {
        NSLog(@"ERR!: %d", err);
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[AppDelegate sharedDelegate].busAttachment leaveJoinedSession:self.sessionID];
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



@end

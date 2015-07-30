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
<AJNSessionListener, AJNProxyBusObjectDelegate, AJNSessionDelegate>

@property (nonatomic, strong) AJNMessage *methodReply;
@property (nonatomic, strong) AJNProxyBusObject *basicObjectProxy;
@property (nonatomic, assign) AJNSessionId sessionID;
@property (nonatomic, strong) AJNProxyBusObject *proxy;

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
    
    
    [[AppDelegate sharedDelegate].busAttachment enableConcurrentCallbacks];

    AJNSessionOptions *opts = [[AJNSessionOptions alloc] initWithTrafficType:kAJNTrafficMessages
                                                          supportsMultipoint:YES
                                                                   proximity:kAJNProximityAny
                                                               transportMask:kAJNTransportMaskAny];

    self.sessionID = [[AppDelegate sharedDelegate].busAttachment joinSessionWithName:self.service.busName
                                                                              onPort:900
                                                                        withDelegate:nil
                                                                             options:opts];

    if(self.sessionID != 0) {
        
        self.proxy = [[AJNProxyBusObject alloc] initWithBusAttachment:[AppDelegate sharedDelegate].busAttachment
                                                          serviceName:self.service.busName
                                                           objectPath:@"/About"
                                                            sessionId:self.sessionID];
        
        [self.proxy introspectRemoteObject];
        
        for(AJNInterfaceDescription *interface in [self.proxy interfaces]) {
            NSLog(@"Interface: %@", interface.name);
            for(AJNInterfaceMember *member in interface.members) {
                NSLog(@"member: %@", member.name);
            }
        }
        
//        AJNMessageArgument *language = [[AJNMessageArgument alloc] init];
//        [language setValue:@"s", ""];
//        [language stabilize];
//        NSArray *args = [[NSArray alloc] initWithObjects:language, nil];
        
        AJNMessage *mr = [[AJNMessage alloc] init];
        QStatus status = [self.proxy callMethodWithName:@"Introspect" // IntrospectWithDescription
                                    onInterfaceWithName:@"org.freedesktop.DBus.Introspectable" //org.allseen.Introspectable
                                          withArguments:nil
                                            methodReply:&mr];
        
        self.methodReply = mr;
        

        if(ER_OK == status) {
            
            NSLog(@"Got it: %@", [self.methodReply xmlDescription]);
            
            for(NSUInteger i=0; i<[self.methodReply arguments].count; i++) {
                AJNMessageArgument *arg = [[self.methodReply arguments] objectAtIndex:i];
                
                const char *variable;
                status = [arg value:@"s", &variable];
                
                NSString *stringvalue = [NSString stringWithUTF8String:variable];
                
                NSLog(@"Unique bus name: %@", stringvalue);
            }

        } else {
            NSLog(@"ERR");
        }
        
        NSLog(@"Here");
        
    } else {
        NSLog(@"Connection err");
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



@end

//
//  Command.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "Command.h"

#import "AJNBusAttachment.h"
#import "AJNBusInterface.h"
#import "AJNProxyBusObject.h"
#import "AppDelegate.h"
#import "ConnectedService.h"
#import "InterfaceObject.h"
#import "InterfaceMethod.h"
#import "InterfaceArgument.h"
#import "NSString+StripTags.h"

#import "XMLDictionary.h"

@interface Command()

<AJNSessionListener, AJNProxyBusObjectDelegate, AJNSessionDelegate>

@property (nonatomic, strong) AJNMessage *methodReply;
@property (nonatomic, strong) AJNProxyBusObject *basicObjectProxy;
@property (nonatomic, assign) AJNSessionId sessionID;
@property (nonatomic, strong) AJNProxyBusObject *proxy;
@property (nonatomic, strong) NSMutableArray *interfaceObjects;


@end

@implementation Command

- (void) run:(NSString*)method onInterface:(NSString*)interface
{
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
                                                           objectPath:@"/ControlPanel"
                                                            sessionId:self.sessionID];
        
        [self.proxy introspectRemoteObject];
        
        
        AJNMessage *mr = [[AJNMessage alloc] init];
        QStatus status = [self.proxy callMethodWithName:method
                                    onInterfaceWithName:interface
                                          withArguments:nil
                                            methodReply:&mr];
        
        self.methodReply = mr;
        
        if(ER_OK == status) {
            
            NSString *xmlString = [self.methodReply xmlDescription];
            NSLog(@"Got: %@", xmlString);
            
        } else {
            NSLog(@"ERR");
        }
        
        NSLog(@"Here");
        
    } else {
        NSLog(@"Connection err");
    }

}

@end

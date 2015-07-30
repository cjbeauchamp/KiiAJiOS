//
//  ConnectedService.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "ConnectedService.h"

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

@interface ConnectedService()

@property (nonatomic, assign) AJNSessionId sessionID;

@property (nonatomic, strong) NSMutableDictionary *proxies;
@property (nonatomic, strong) AJNMessage *methodReply;

@end

@implementation ConnectedService

- (id) init
{
    self = [super init];
    self.pathObjects = [[NSMutableArray alloc] init];
    self.proxies = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) run:(NSString*)method onInterface:(NSString*)interface usingPath:(NSString*)usingPath
{
    [[AppDelegate sharedDelegate].busAttachment enableConcurrentCallbacks];
    
    AJNProxyBusObject *proxy = [self.proxies objectForKey:usingPath];
    
    if(proxy != nil) {
        AJNMessage *mr = [[AJNMessage alloc] init];
        QStatus status = [proxy callMethodWithName:method
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
    } else {
        NSLog(@"No proxy found");
    }

}

- (InterfaceObject*) addInterface:(NSString*)interfaceName
               atPath:(NSString*)path
{
    ServicePathObject *pathObj = nil;
    for(ServicePathObject *o in self.pathObjects) {
        
        if([o.name isEqualToString:path]) {
            pathObj = o;
        }
    }
    
    if(pathObj == nil) {
        pathObj = [[ServicePathObject alloc] init];
        pathObj.name = path;
        [self.pathObjects addObject:pathObj];
    }
    
    return [pathObj addInterface:interfaceName];
}

- (void) connect
{
    [[AppDelegate sharedDelegate].busAttachment enableConcurrentCallbacks];

    KiiBucket *bucket = [Kii bucketWithName:@"localDevices"];
    KiiObject *object = [bucket createObjectWithID:[self.deviceID md5]];
    [object setObject:self.deviceName forKey:@"deviceName"];
    [object setObject:self.appName forKey:@"appName"];
    [object setObject:self.appID forKey:@"appID"];
    [object setObject:self.deviceID forKey:@"deviceID"];
    [object setObject:self.manufacturer forKey:@"manufacturer"];
    
    NSError *err = nil;
    [object saveAllFieldsSynchronous:YES withError:&err];
    NSLog(@"Saved: %@", err);
    
    AJNSessionOptions *opts = [[AJNSessionOptions alloc] initWithTrafficType:kAJNTrafficMessages
                                                          supportsMultipoint:YES
                                                                   proximity:kAJNProximityAny
                                                               transportMask:kAJNTransportMaskAny];
    
    self.sessionID = [[AppDelegate sharedDelegate].busAttachment joinSessionWithName:self.busName
                                                                              onPort:25
                                                                        withDelegate:nil
                                                                             options:opts];

    if(self.sessionID != 0) {
        
        for(NSString *path in self.interfacePaths.allKeys) {
            
            NSLog(@"Inspecting path: %@", path);
            
            AJNProxyBusObject *proxy = [[AJNProxyBusObject alloc] initWithBusAttachment:[AppDelegate sharedDelegate].busAttachment
                                                                            serviceName:self.busName
                                                                             objectPath:path
                                                                              sessionId:self.sessionID];

            [self.proxies setObject:proxy forKey:path];
            
            [proxy introspectRemoteObject];
            
            for(AJNInterfaceDescription *interface in [proxy interfaces]) {
                
                InterfaceObject *interfaceObj = [self addInterface:interface.name atPath:path];

                NSLog(@"Interface: %@", interface.name);
                for(AJNInterfaceMember *member in interface.members) {
                    
                    NSLog(@"member: %@", member.name);
                    [interfaceObj addMethod:member.name];
                }
            }
            
            KiiBucket *bucket = [Kii bucketWithName:@"localDevices"];
            KiiObject *object = [bucket createObjectWithID:[self.deviceID md5]];
            [object setObject:self.deviceName forKey:@"deviceName"];
            [object setObject:self.appName forKey:@"appName"];
            [object setObject:self.appID forKey:@"appID"];
            [object setObject:self.deviceID forKey:@"deviceID"];
            [object setObject:self.manufacturer forKey:@"manufacturer"];

            NSMutableArray *arr = [NSMutableArray array];
            for(ServicePathObject *o in self.pathObjects) {
                [arr addObject:[o dictValue]];
            }
            [object setObject:arr forKey:@"interfaces"];
            
            NSLog(@"SAving interfaces for device: %@ => %@", self.deviceName, arr);
            
            [object saveAllFields:YES
                        withBlock:^(KiiObject *object, NSError *error) {
                NSLog(@"Object saved: %@", error);
            }];
        }
        
    } else {
        NSLog(@"Connection err");
    }
}

@end

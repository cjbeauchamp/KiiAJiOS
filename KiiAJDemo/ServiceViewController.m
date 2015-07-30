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

#import "XMLDictionary.h"

#import <KiiSDK/Kii.h>

@interface ServiceViewController ()
<AJNSessionListener, AJNProxyBusObjectDelegate, AJNSessionDelegate>

@property (nonatomic, strong) AJNMessage *methodReply;
@property (nonatomic, strong) AJNProxyBusObject *basicObjectProxy;
@property (nonatomic, assign) AJNSessionId sessionID;
@property (nonatomic, strong) AJNProxyBusObject *proxy;
@property (nonatomic, strong) NSMutableArray *interfaceObjects;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.interfaceObjects = [[NSMutableArray alloc] init];
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
            
            InterfaceObject *o = [[InterfaceObject alloc] init];
            o.name = interface.name;
            
            NSLog(@"Interface: %@", interface.name);
            for(AJNInterfaceMember *member in interface.members) {
                
                NSLog(@"member: %@", member.name);

                InterfaceMethod *method = [[InterfaceMethod alloc] init];
                method.name = member.name;
                [o.methods addObject:method];
            }
            
            [self.interfaceObjects addObject:o];
        }
        
        KiiBucket *bucket = [Kii bucketWithName:@"localDevices"];
        KiiObject *object = [bucket createObjectWithID:[self.service.deviceID md5]];
        [object setObject:self.service.deviceName forKey:@"deviceName"];
        [object setObject:self.service.appName forKey:@"appName"];
        [object setObject:self.service.appID forKey:@"appID"];
        [object setObject:self.service.deviceID forKey:@"deviceID"];
        [object setObject:self.service.manufacturer forKey:@"manufacturer"];

        NSMutableArray *arr = [NSMutableArray array];
        for(InterfaceObject *o in self.interfaceObjects) {
            [arr addObject:[o dictValue]];
        }
        [object setObject:arr forKey:@"interfaces"];
        
        [object saveAllFields:YES withBlock:^(KiiObject *object, NSError *error) {
            NSLog(@"Object saved: %@", error);
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

//        AJNMessage *mr = [[AJNMessage alloc] init];
//        QStatus status = [self.proxy callMethodWithName:@"Introspect"
//                                    onInterfaceWithName:@"org.freedesktop.DBus.Introspectable"
//                                          withArguments:nil
//                                            methodReply:&mr];
//        
//        self.methodReply = mr;
//        
//        if(ER_OK == status) {
//            
//            NSString *xmlString = [self.methodReply xmlDescription];
//            
//            NSError *error = nil;
//            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<![^>]*>"
//                                                                                   options:0
//                                                                                     error:&error];
//            
//            xmlString = [regex stringByReplacingMatchesInString:xmlString
//                                                        options:0
//                                                          range:NSMakeRange(0, [xmlString length])
//                                                   withTemplate:@""];
//            
//            NSLog(@"XML: %@", xmlString);
//            
//            NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:xmlString];
//            
//            @try {
//                NSArray *interfaces = xmlDict[@"body"][@"string"][@"node"][@"interface"];
//
//                for(NSDictionary *i in interfaces) {
////                    NSLog(@"O: %@", i);
//                    InterfaceObject *o = [[InterfaceObject alloc] init];
//                    o.name = i[@"_name"];
//                    
//                    NSArray *methods = i[@"method"];
//                    if(![i[@"method"] isKindOfClass:[NSArray class]]) {
//                        methods = @[i[@"method"]];
//                    }
//                    
//                    for(NSDictionary *m in methods) {
////                        NSLog(@"M: %@", m);
//                        InterfaceMethod *method = [[InterfaceMethod alloc] init];
//                        method.name = m[@"_name"];
//                        
//                        NSArray *args = m[@"arg"];
//                        if(![m[@"arg"] isKindOfClass:[NSArray class]]) {
//                            args = @[m[@"arg"]];
//                        }
//
//                        for(NSDictionary *a in args) {
////                            NSLog(@"A: %@", a);
//                            InterfaceArgument *argument = [[InterfaceArgument alloc] init];
//                            argument.name = a[@"_name"];
//                            argument.direction = a[@"_direction"];
//                            argument.type = a[@"_type"];
//                            [method.arguments addObject:argument];
//                        }
//                        
//                        [o.methods addObject:method];
//                    }
//
//                    [self.interfaceObjects addObject:o];
//                }
//                
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            }
//            @catch (NSException *exception) {
//                NSLog(@"Keys must not have existed");
//            }
//            
//        } else {
//            NSLog(@"ERR");
//        }
        
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

#pragma mark - Table view data source
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    InterfaceObject *o = [self.interfaceObjects objectAtIndex:section];
    return o.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.interfaceObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    InterfaceObject *o = [self.interfaceObjects objectAtIndex:section];
    return o.methods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    InterfaceObject *o = [self.interfaceObjects objectAtIndex:indexPath.section];
    InterfaceMethod *m = [o.methods objectAtIndex:indexPath.row];

    // Configure the cell...
    cell.textLabel.text = m.name;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InterfaceObject *o = [self.interfaceObjects objectAtIndex:indexPath.section];
    InterfaceMethod *m = [o.methods objectAtIndex:indexPath.row];
    
    AJNMessage *mr = [[AJNMessage alloc] init];
    QStatus status = [self.proxy callMethodWithName:m.name
                                onInterfaceWithName:o.name
                                      withArguments:nil
                                        methodReply:&mr];
    
    self.methodReply = mr;
    
    if(ER_OK == status) {
        NSLog(@"Worked!");
    } else {
        NSLog(@"Failed!");
    }

}



@end

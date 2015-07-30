//
//  Command.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectedService;
@interface Command : NSObject

@property (nonatomic, strong) ConnectedService *service;

- (void) run:(NSString*)method onInterface:(NSString*)interface;

@end

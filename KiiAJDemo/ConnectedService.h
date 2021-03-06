//
//  ConnectedService.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/29/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectedService : NSObject

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *busName;
@property (nonatomic, strong) NSDictionary *interfacePaths;
@property (nonatomic, assign) u_int16_t port;

@property (nonatomic, strong) NSMutableArray *pathObjects;

- (void) connect;

- (void) run:(NSString*)method
 onInterface:(NSString*)interface
   usingPath:(NSString*)usingPath;

@end

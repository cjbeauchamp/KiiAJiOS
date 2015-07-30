//
//  ServicePathObject.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InterfaceObject;
@interface ServicePathObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *interfaces;

- (NSDictionary*) dictValue;
- (InterfaceObject*) addInterface:(NSString*)interfaceName;

@end

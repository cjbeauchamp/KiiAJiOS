//
//  InterfaceObject.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "InterfaceObject.h"

@implementation InterfaceObject

- (id) init
{
    self = [super init];
    self.methods = [[NSMutableArray alloc] init];
    return self;
}

@end

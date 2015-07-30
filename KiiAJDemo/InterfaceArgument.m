//
//  InterfaceArgument.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "InterfaceArgument.h"

@implementation InterfaceArgument

- (NSDictionary*) dictValue
{
    return @{
             @"name": self.name,
             @"direction": self.direction,
             @"type": self.type
             };
}


@end

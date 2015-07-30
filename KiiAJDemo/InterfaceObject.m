//
//  InterfaceObject.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "InterfaceObject.h"

#import "InterfaceMethod.h"

@implementation InterfaceObject

- (id) init
{
    self = [super init];
    self.methods = [[NSMutableArray alloc] init];
    return self;
}

- (NSDictionary*) dictValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.name forKey:@"name"];
    [dict setObject:self.path forKey:@"path"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(InterfaceMethod *m in self.methods) {
        [arr addObject:[m dictValue]];
    }
    
    [dict setObject:arr forKey:@"methods"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

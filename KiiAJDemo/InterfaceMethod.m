//
//  InterfaceMethod.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "InterfaceMethod.h"
#import "InterfaceArgument.h"

@implementation InterfaceMethod

- (id) init
{
    self = [super init];
    self.arguments = [[NSMutableArray alloc] init];
    return self;
}

- (NSDictionary*) dictValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.name forKey:@"name"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(InterfaceArgument *a in self.arguments) {
        [arr addObject:[a dictValue]];
    }
    
    [dict setObject:arr forKey:@"arguments"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

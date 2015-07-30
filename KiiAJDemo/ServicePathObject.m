//
//  ServicePathObject.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "ServicePathObject.h"
#import "InterfaceObject.h"

@implementation ServicePathObject

- (id) init
{
    self = [super init];
    
    self.interfaces = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSDictionary*) dictValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.name forKey:@"name"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(InterfaceObject *m in self.interfaces) {
        [arr addObject:[m dictValue]];
    }
    
    [dict setObject:arr forKey:@"interfaces"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (InterfaceObject*) addInterface:(NSString*)interfaceName
{
    InterfaceObject *interfaceObj = nil;
    for(InterfaceObject *o in self.interfaces) {
        if([[o name] isEqualToString:interfaceName]) {
            interfaceObj = o;
        }
    }
    
    if(interfaceObj == nil) {
        interfaceObj = [[InterfaceObject alloc] init];
        interfaceObj.name = interfaceName;
        [self.interfaces addObject:interfaceObj];
    }
    
    return interfaceObj;
}

@end

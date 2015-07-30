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

- (void) addMethod:(NSString*)methodName
{
    BOOL found = FALSE;
    for(InterfaceMethod *m in self.methods) {
        if([m.name isEqualToString:methodName]) {
            found = TRUE;
        }
    }
    
    if(!found) {
        InterfaceMethod *m = [[InterfaceMethod alloc] init];
        m.name = methodName;
        m.interfaceName = self.name;
        [self.methods addObject:m];
    }
}

- (NSDictionary*) dictValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.name forKey:@"name"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(InterfaceMethod *m in self.methods) {
        [arr addObject:[m dictValue]];
    }
    
    [dict setObject:arr forKey:@"methods"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

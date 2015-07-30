//
//  InterfaceObject.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InterfaceObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *methods;

- (NSDictionary*) dictValue;
- (void) addMethod:(NSString*)methodName;

@end

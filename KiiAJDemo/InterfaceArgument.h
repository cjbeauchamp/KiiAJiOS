//
//  InterfaceArgument.h
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InterfaceArgument : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSString *type;

- (NSDictionary*) dictValue;

@end

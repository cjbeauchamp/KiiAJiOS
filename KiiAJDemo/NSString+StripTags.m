//
//  NSString+StripTags.m
//  KiiAJDemo
//
//  Created by Chris Beauchamp on 7/30/15.
//  Copyright (c) 2015 Kii. All rights reserved.
//

#import "NSString+StripTags.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (StripTags)

- (NSString*) stripTags
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>"
                                                                           options:0
                                                                             error:&error];
    
    NSString *newString = [regex stringByReplacingMatchesInString:self
                                                options:0
                                                  range:NSMakeRange(0, [self length])
                                           withTemplate:@""];

    return newString;
}


- (NSString*) md5
{
    unsigned char result[16];
    const char *cStr = [self UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
    
}

@end

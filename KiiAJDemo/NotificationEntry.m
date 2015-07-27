/******************************************************************************
 * Copyright AllSeen Alliance. All rights reserved.
 *
 *    Permission to use, copy, modify, and/or distribute this software for any
 *    purpose with or without fee is hereby granted, provided that the above
 *    copyright notice and this permission notice appear in all copies.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 ******************************************************************************/


#import "NotificationEntry.h"
#import "NotificationUtils.h"
#import "AppDelegate.h"
#import "alljoyn/services_common/AJSVCGenericLoggerDefaultImpl.h"

@interface NotificationEntry ()
@property (strong, nonatomic) AJNSNotification *ajnsNotification;

@end

@implementation NotificationEntry

- (id)initWithAJNSNotification:(AJNSNotification *) ajnsNotification
{
    self = [super init];
    if (self) {
        self.ajnsNotification = ajnsNotification;
    }
    return self;
}


-(void)setAjnsNotification:(AJNSNotification *)ajnsNotification
{
  
    _ajnsNotification = ajnsNotification;
  
    //show AJNSNotification on self.notificationTextView
    NSString *nstr = @"";
    NSString *lang;
    
    nstr = [nstr stringByAppendingString:[AJNSNotificationEnums AJNSMessageTypeToString:[ajnsNotification messageType]]];
    nstr = [nstr stringByAppendingFormat:@" "];
    
    // get the msg NotificationText

    for (AJNSNotificationText *nt in ajnsNotification.ajnsntArr) {
        nstr = [nstr stringByAppendingString:lang];
        nstr = [nstr stringByAppendingFormat:@": "];
        nstr = [nstr stringByAppendingString:[nt getText]];
        nstr = [nstr stringByAppendingFormat:@" "];
    } //for
    
    // get the msg NotificationText
    NSString *richIconUrl = [ajnsNotification richIconUrl];
    if ([NotificationUtils textFieldIsValid:richIconUrl]) {
        nstr = [nstr stringByAppendingFormat:@"\nicon: %@", richIconUrl];
    }
    
    // get the msg richAudioUrl
    __strong NSMutableArray *richAudioUrlArray = [[NSMutableArray alloc] init];
    
    [ajnsNotification richAudioUrl:richAudioUrlArray];
    int i = 0;
    for (int x = 0; x != [richAudioUrlArray count]; x++) {
        [[AppDelegate sharedDelegate].logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"%d", i]];
        i++;
        NSString *lang = [(AJNSRichAudioUrl *)[richAudioUrlArray objectAtIndex:x] language];
        NSString *audiourl = [(AJNSRichAudioUrl *)[richAudioUrlArray objectAtIndex:x] url];
        [[AppDelegate sharedDelegate].logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"lang[%@]", lang]];
        [[AppDelegate sharedDelegate].logger debugTag:[[self class] description] text:[NSString stringWithFormat:@"audiourl[%@]", audiourl]];
        nstr = [nstr stringByAppendingFormat:@"\naudio: %@", audiourl];
    } //for
    
    [[AppDelegate sharedDelegate].logger debugTag:[[self class] description] text:([NSString stringWithFormat:@"Adding notification to view:\n %@", nstr])];
    
    
    self.text = nstr;
}

@end

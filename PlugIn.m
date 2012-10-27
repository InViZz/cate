//
//  PlugIn.m
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import "PlugIn.h"

void CTTelephonyCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
CFNotificationCenterRef CTTelephonyCenterGetDefault(void);
void CTCallDisconnect(CTCall *call);
NSString *CTCallCopyAddress(void *, CTCall *call);

static void callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if ([ (NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
        CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
        NSString *caller = CTCallCopyAddress(NULL, call);
        NSLog(@"caller is %@", caller);
        CTCallDisconnect(call);
        // CTCallAnswer
        // CTCallGetStatus
        // CTCallGetGetRowIDOfLastInsert
    }
}

@implementation PlugIn

+ (void)hook {
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, callback, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
}

@end

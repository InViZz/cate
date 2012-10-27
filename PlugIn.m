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
    if ([PlugIn enabled] && [(NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
        CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
        NSInteger status = [[(NSDictionary *)userInfo objectForKey:@"kCTCallStatus"] intValue];
        if (status == 4) { // incoming
            NSString *caller = CTCallCopyAddress(NULL, call);
            NSLog(@"caller is %@", caller);
            [caller release];
            CTCallDisconnect(call);
        }
    }
}

@implementation PlugIn

+ (void)hook {
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, callback, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
}

static NSString *kPrefPath = @"/var/mobile/Library/Preferences/com.shaohua.cate.plist";
static NSString *kEnabledKey = @"enabled";

+ (BOOL)enabled {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];
    return [[plist objectForKey:kEnabledKey] boolValue];
}

+ (void)setEnabled:(BOOL)enabled {
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefPath]
    ?: [NSMutableDictionary dictionary];
    [plist setObject:[NSNumber numberWithBool:enabled] forKey:kEnabledKey];
    [plist writeToFile:kPrefPath atomically:YES];
}

@end

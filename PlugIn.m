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

            NSArray *contacts = [PlugIn blacklisted];
            for (NSDictionary *person in contacts) {
                for (NSString *number in [person objectForKey:@"numbers"]) {
                    if ([caller isEqualToString:number]) {
                        NSLog(@"caller %@ is blacklisted", caller);
                        CTCallDisconnect(call);
                        goto outer;
                    }
                }
            }
        outer:
            [caller release];
        }
    }
}

@implementation PlugIn

+ (void)hook {
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, callback, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
}

static NSString *kPrefPath = @"/var/mobile/Library/Preferences/com.shaohua.cate.plist";
static NSString *kEnabledKey = @"enabled";
static NSString *kBlacklistedKey = @"blacklisted";

#pragma mark - Private
+ (id)objectForKey:(id)key {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];
    return [plist objectForKey:key];
}

+ (void)setObject:(id)object forKey:(id)key {
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefPath]
        ?: [NSMutableDictionary dictionary];
    [plist setObject:object forKey:key];
    [plist writeToFile:kPrefPath atomically:YES];
}

#pragma mark - Public
+ (BOOL)enabled {
    return [[self objectForKey:kEnabledKey] boolValue];
}

+ (void)setEnabled:(BOOL)enabled {
    [self setObject:[NSNumber numberWithBool:enabled] forKey:kEnabledKey];
}

+ (NSMutableArray *)blacklisted {
    return [NSMutableArray arrayWithArray:[self objectForKey:kBlacklistedKey]];
}

+ (void)setBlacklisted:(NSArray *)blacklisted {
    [self setObject:blacklisted forKey:kBlacklistedKey];
}

@end

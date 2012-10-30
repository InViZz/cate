//
//  PlugIn.m
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import "PlugIn.h"

typedef struct __CTCall *CTCallRef;

void CTTelephonyCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
CFNotificationCenterRef CTTelephonyCenterGetDefault(void);
void CTCallDisconnect(CTCallRef call);
NSString *CTCallCopyAddress(void *, CTCallRef call);


@interface CTMessageCenter
+ (id)sharedMessageCenter;
- (id)incomingMessageWithId:(unsigned)anId;
- (int)incomingMessageCount;
- (id)allIncomingMessages;
@end


@protocol CTMessageAddress
- (id)encodedString;
- (id)canonicalFormat;
@end


@interface CTMessage
@property (assign, nonatomic) int messageType;
@property (copy, nonatomic) NSObject <CTMessageAddress> *sender; // CTPhoneNumber
@property (readonly, assign) NSArray *items;

@end

@interface CTMessagePart
@property (copy, nonatomic) NSData *data;

@end

static void callStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef nameRef, const void *object, CFDictionaryRef userInfoRef) {
    NSDictionary *userInfo = (NSDictionary *)userInfoRef;

    if ([PlugIn enabled]) {
        CTCallRef call = (CTCallRef)[userInfo objectForKey:@"kCTCall"];
        NSInteger status = [[userInfo objectForKey:@"kCTCallStatus"] intValue];
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

static void messageReceived(CFNotificationCenterRef center, void *observer, CFStringRef nameRef, const void *object, CFDictionaryRef userInfoRef) {
    NSString *name = (NSString *)nameRef;
    NSDictionary *userInfo = (NSDictionary *)userInfoRef;
    NSLog(@"%@ %@", name, userInfo);
    // kCTMessageIdKey = "-2147483628";
    // kCTMessageTypeKey = 1;

    if ([PlugIn enabled]) {
        CTMessageCenter *center = [CTMessageCenter sharedMessageCenter];
        int messageId = [[userInfo objectForKey:@"kCTMessageIdKey"] intValue];
        id message = [center incomingMessageWithId:messageId];
        id sender = [message sender];
        NSString *number = [sender canonicalFormat];

        NSLog(@"msg %@, sender %@, number %@", message, [message sender], number);
        NSArray *items = [message items];
        // print first part
        if ([items count]) {
            id part = [items objectAtIndex:0];
            NSLog(@"data=%@", [[NSString alloc] initWithData:[part data] encoding:NSUTF8StringEncoding]);

        }
    }
}

@implementation PlugIn

extern CFStringRef kCTMessageReceivedNotification;
extern CFStringRef kCTCallStatusChangeNotification;

+ (void)hook {
    CFNotificationCenterRef center = CTTelephonyCenterGetDefault();
    CTTelephonyCenterAddObserver(center, NULL, callStatusChanged,  kCTCallStatusChangeNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    CTTelephonyCenterAddObserver(center, NULL, messageReceived, kCTMessageReceivedNotification, NULL, CFNotificationSuspensionBehaviorDrop);
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

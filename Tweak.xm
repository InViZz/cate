
typedef struct __GSEvent *GSEventRef;
typedef struct _opaque_pthread_t opaque_pthread_t;

#import <SpringBoard/SpringBoard.h>

#import "PlugIn.h"

// ================================================================================================
//
// Phone Call
//
// ================================================================================================
#pragma mark - hook CFNotificationCenterPostNotification

#define MSHook(type, name, args...) \
static type (*_ ## name)(args); \
static type $ ## name(args)

typedef struct __CTCall *CTCallRef;

extern "C" {
void CTCallDisconnect(CTCallRef call);
NSString *CTCallCopyAddress(void *, CTCallRef call);
void CFNotificationCenterPostNotification(CFNotificationCenterRef center, CFStringRef name, const void *object, CFDictionaryRef userInfo, Boolean deliverImmediately);
}

MSHook(void, CFNotificationCenterPostNotification, CFNotificationCenterRef center, CFStringRef nameRef, const void *object, CFDictionaryRef userInfo, Boolean deliverImmediately) {
    extern NSString *kCTCallStatusChangeNotification;
    extern NSString *kCTCallIdentificationChangeNotification;
    extern NSString *kCTCallHistoryRecordAddNotification;

    NSLog(@"MSHook name=%@ userInfo=%@", nameRef, userInfo);
    NSString *name = (NSString *)nameRef;
    BOOL toFilter = [name isEqualToString:kCTCallStatusChangeNotification]
    || [name isEqualToString:kCTCallIdentificationChangeNotification] // SBUIFullscreenAlertAdapter
    || [name isEqualToString:kCTCallHistoryRecordAddNotification]; // SBAwayBulletinListController

    if (toFilter && [PlugIn isEnabled]) {
        NSDictionary *info = (NSDictionary *)userInfo;
        NSInteger status = [[info objectForKey:@"kCTCallStatus"] intValue];
        CTCallRef call = (CTCallRef)[info objectForKey:@"kCTCall"];
        NSString *number = CTCallCopyAddress(NULL, call);

        if ([PlugIn isNumberBlacklisted:number]) {
            if (status == 4) { // incoming
                NSLog(@"%@ got dropped for phone number %@", name, number);
                CTCallDisconnect(call);
            }
            [number release];
            return; // filter out this notification
        }
    }
    _CFNotificationCenterPostNotification(center, nameRef, object, userInfo, deliverImmediately);
}


// ================================================================================================
//
// SMS Related
//
// ================================================================================================
#pragma mark - hook SMSCTServer

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


%hook SMSCTServer

- (void)_ingestIncomingCTMessage:(CTMessage *)message {
    %log;
    if ([PlugIn isEnabled]) {
        NSString *number = [message.sender canonicalFormat];
        NSLog(@"sender=%@, number=%@", message.sender, number);

        // print first part
        NSArray *items = [message items];
        if ([items count]) {
            id part = [items objectAtIndex:0];
            NSString *text = [[NSString alloc] initWithData:[part data] encoding:NSUTF8StringEncoding];
            NSLog(@"content=%@", text);
            [text release];
        }

        if ([PlugIn isNumberBlacklisted:number]) {
            NSLog(@"text message from caller %@ has been filtered", number);
            return;
        }
    }
    %orig;
}

%end


// ================================================================================================
//
// Entry Point
//
// ================================================================================================
#pragma mark - hook SpringBoard

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %log;
    NSLog(@"========================== SpringBoard Restarted ==========================");
    %orig;

    MSHookFunction((void *)CFNotificationCenterPostNotification, (void *)$CFNotificationCenterPostNotification, (void **)&_CFNotificationCenterPostNotification);
}

%end

%hook PhoneApplication
-(void)applicationDidFinishLaunching:(id)application {
    %log;
    NSLog(@"========================== MobilePhone Restarted ==========================");
    %orig;

    MSHookFunction((void *)CFNotificationCenterPostNotification, (void *)$CFNotificationCenterPostNotification, (void **)&_CFNotificationCenterPostNotification);
}

%end


typedef struct __GSEvent *GSEventRef;
typedef struct _opaque_pthread_t opaque_pthread_t;

#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBSMSAlertItem.h>

#import "PlugIn.h"

typedef struct __CTCall *CTCallRef;

extern "C" void CTCallDisconnect(CTCallRef call);
extern "C" NSString *CTCallCopyAddress(void *, CTCallRef call);

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

%hook CTCallCenter
- (id)description { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)broadcastCallStateChangesIfNeededWithFailureLogMessage:(id)arg1 { %log; %orig; }

- (void)handleNotificationFromConnection:(void *)arg1 ofType:(id)arg2 withInfo:(NSDictionary *)info {
    %log;
    if ([PlugIn isEnabled]) {
        CTCallRef call = (CTCallRef)[info objectForKey:@"kCTCall"];
        NSInteger status = [[info objectForKey:@"kCTCallStatus"] intValue];
        if (status == 4) { // incoming
            NSString *number = [CTCallCopyAddress(NULL, call) autorelease];

            if ([PlugIn isNumberBlacklisted:number]) {
                NSLog(@"call from %@ has been filtered", number);
                CTCallDisconnect(call);
                return;
            }
        }
    }
    %orig;
}

- (void)setCurrentCalls:(NSSet *)currentCalls { %log; %orig; }
- (NSSet *)currentCalls { %log; NSSet * r = %orig; NSLog(@" = %@", r); return r; }
- (BOOL)calculateCallStateChanges:(id)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (BOOL)getCurrentCallSetFromServer:(id)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (void)setCallEventHandler:(id )callEventHandler { %log; %orig; }
- (id )callEventHandler { %log; id  r = %orig; NSLog(@" = %@", r); return r; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)cleanUpServerConnection { %log; %orig; }
- (BOOL)setUpServerConnection { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
%end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %orig;
}

%end

%hook SBAlertItemsController
-(void)activateAlertItem:(id)item {
    // It's an SMS/MMS!
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %log;
    if ([item isKindOfClass:objc_getClass("SBSMSAlertItem")]) {
        // ignore
    } else {
        %orig;
    }
}
%end

%hook SBAwayBulletinListController

- (void)_updateModelAndTableViewForAddition:(id)addition {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %orig;
}

- (void)clearViewsAndHibernate {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %orig;
}

%end

%hook SBCallAlert
- (id)initWithCall:(id)arg1 {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook SBPluginManager

- (Class)loadPluginBundle:(id)bundle {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook SBUIController

- (void)activateApplicationAnimated:(id)animated {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %orig;
}
%end

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

%hook BBBulletin

- (id)responseForDefaultAction {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook BBAction

+ (id)actionWithLaunchURL:(NSURL *)arg1 callblock:(id)arg2 {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook CKConversationList

- (id)init {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook MPIncomingPhoneCallController
-(id)initWithCall:(CTCallRef)call {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

%hook SBUIFullscreenAlertAdapter
- (id)initWithAlertController:(MPIncomingPhoneCallController *)arg1 {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    return %orig;
}

%end

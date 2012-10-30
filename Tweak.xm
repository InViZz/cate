typedef struct __GSEvent *GSEventRef;
typedef struct _opaque_pthread_t opaque_pthread_t;
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBSMSAlertItem.h>

#import <CoreTelephony/CTCall.h>
#import <objc/runtime.h>

#import "PlugIn.h"

typedef struct {
    struct __CFRuntimeBase {
        unsigned int _cfisa;
        unsigned char _cfinfo[4];
    } _field1;
    int _field2;
    int _field3;
} CKSMSRecord;

%hook CTCallCenter
- (id)description { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)broadcastCallStateChangesIfNeededWithFailureLogMessage:(id)arg1 { %log; %orig; }

- (void)handleNotificationFromConnection:(void *)arg1 ofType:(id)arg2 withInfo:(NSDictionary *)info {
    %log;
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
    %orig;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to your iPhone Brandon!" delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
    [alert show];
    [alert release];

    [PlugIn hook];
}

%end

%hook SBAlertItemsController
-(void)activateAlertItem:(id)item {
    // It's an SMS/MMS!
    %log;
    if ([item isKindOfClass:objc_getClass("SBSMSAlertItem")]) {
        // ignore
    } else {
        %orig;
    }
}
%end

%hook SBAwayBulletinListController

- (void)clearViewsAndHibernate {
    %log;
    NSLog(@"*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    %orig;
}

%end

%hook CKSMSService
- (void)_receivedMessage:(id)arg1 replace:(BOOL)arg2 replacedRecordIdentifier:(int)arg3 postInternalNotification:(BOOL)arg4 {
    %log;
    NSLog(@"class %@", [arg1 class]);

    %orig;
}

- (void)_receivedMessage:(id)arg1 replace:(BOOL)arg2 postInternalNotification:(BOOL)arg3 {
    %log;
    NSLog(@"class %@", [arg1 class]);

    %orig;
}

%end

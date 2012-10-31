//
//  PlugIn.m
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import "PlugIn.h"

@implementation PlugIn

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
+ (BOOL)isEnabled {
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

+ (BOOL)isNumberBlacklisted:(NSString *)candidate {
    if ([candidate length]) {
        NSArray *contacts = [self objectForKey:kBlacklistedKey];
        for (NSDictionary *person in contacts) {
            for (NSString *number in [person objectForKey:@"numbers"]) {
                if ([number isEqualToString:candidate]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end

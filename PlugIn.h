//
//  PlugIn.h
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCall.h>

@interface PlugIn : NSObject

// getters and setters
+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)enabled;

+ (NSMutableArray *)blacklisted;
+ (void)setBlacklisted:(NSArray *)blacklisted;

+ (BOOL)isNumberBlacklisted:(NSString *)number;

@end

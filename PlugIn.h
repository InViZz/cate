//
//  PlugIn.h
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCall.h>

#define TRACE() NSLog(@"[%@ %s]", [self class], (char *)_cmd)

@interface PlugIn : NSObject

+ (void)hook;

@end

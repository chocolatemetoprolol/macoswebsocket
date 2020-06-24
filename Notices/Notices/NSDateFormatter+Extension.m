//
//  NSDateFormatter+Extension.m
//  Notices
//
//  Created by 11 on 2020/6/10.
//  Copyright © 2020 arron. All rights reserved.
//

#import "NSDateFormatter+Extension.h"

@implementation NSDateFormatter (Extension)

+ (instancetype)sharedDateFormatter
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc]init];
    });
    return instance;
}

@end

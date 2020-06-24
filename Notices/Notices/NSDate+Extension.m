//
//  NSDate+Extension.m
//  Notices
//
//  Created by 11 on 2020/4/24.
//  Copyright © 2020 1. All rights reserved.
//

#import "NSDate+Extension.h"
#import "NSDateFormatter+Extension.h"

@implementation NSDate (Extension)

+ (NSString *)getDateStringWithDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter sharedDateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [NSDate now];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    return currentDateStr;
}

@end

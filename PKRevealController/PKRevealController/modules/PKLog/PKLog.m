//
//  PKLog.m
//  PKRevealController
//
//  Created by Philip Kluz on 7/6/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "PKLog.h"
#import <libgen.h>

#define STACK_IDX 0
#define FRAMEWORK_IDX 1
#define MEMORY_ADDR_IDX 2
#define CLASS_CALLER_IDX 3
#define FUNCTION_CALLER_IDX 4
#define LINE_CALLER_IDX 5

void PKLog(NSString *format, ...)
{
#ifdef DEBUG
    if (format)
    {
        NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:separatorSet]];
        [array removeObject:@""];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss:SSS"];
        
        va_list argumentList;
        va_start(argumentList, format);
        
        NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:argumentList];
        
        const char *class = [[array objectAtIndex:CLASS_CALLER_IDX] UTF8String];
        const char *line = [[array objectAtIndex:LINE_CALLER_IDX] UTF8String];
        const char *formattedCString = [[formattedString stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String];
        const char *dateTime = [[dateFormatter stringFromDate:[NSDate date]] UTF8String];
        
        printf("%s [%s:%s] - %s\n", dateTime, class, line, formattedCString);
        
        va_end(argumentList);
    }
#endif
}

/*
    PKRevealController > PKLog.m
    Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
 
    The MIT License (MIT)
 
    Copyright (c) 2013 Philip Kluz
 
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
 
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
 
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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

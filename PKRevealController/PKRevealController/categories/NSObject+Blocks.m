//
//  NSObject+Blocks.m
//  PKRevealController
//
//  Created by Philip Kluz on 6/30/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "NSObject+Blocks.h"

@implementation NSObject (Blocks)

- (void)performBlock:(void(^)(void))block onMainThread:(BOOL)mainThread
{
    if (!block) return;
    
    if (mainThread)
    {
        if ([NSThread isMainThread])
        {
            block();
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                block();
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
        {
            block();
        });
    }
}

@end

//
//  NSObject+Blocks.h
//  PKRevealController
//
//  Created by Philip Kluz on 6/30/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Blocks)

#pragma mark - Methods
- (void)performBlock:(void(^)(void))block onMainThread:(BOOL)mainThread;

@end

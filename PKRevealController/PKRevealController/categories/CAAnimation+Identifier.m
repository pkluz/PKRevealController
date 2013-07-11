//
//  CAAnimation+Identifier.h
//  PKRevealController
//
//  Created by Philip Kluz on 7/8/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "CAAnimation+Identifier.h"
#import <objc/runtime.h>

@implementation CAAnimation (Identifier)

static char identifierKey;

- (void)setIdentifier:(NSInteger)identifier
{
    objc_setAssociatedObject(self, &identifierKey, [NSNumber numberWithInteger:identifier], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)identifier
{
    return [objc_getAssociatedObject(self, &identifierKey) integerValue];
}

@end

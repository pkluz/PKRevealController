//
//  PKRevealControllerType.h
//  PKRevealController
//
//  Created by Trystan Pfluger on 2/04/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, PKRevealControllerType)
{
    PKRevealControllerTypeNone  = 0,
    PKRevealControllerTypeLeft  = 1 << 0,
    PKRevealControllerTypeRight = 1 << 1,
    PKRevealControllerTypeBoth = (PKRevealControllerTypeLeft | PKRevealControllerTypeRight)
};

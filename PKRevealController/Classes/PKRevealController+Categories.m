//
//  UIViewController+PKRevealController.m
//  PKRevealController
//
//  Created by Philip Kluz on 12/26/12.
//  Copyright (c) 2012 zuui.org. All rights reserved.
//

#import "PKRevealController+Categories.h"
#import "PKRevealController.h"
#import <objc/runtime.h>

@implementation UIViewController (PKRevealController)

static char revealControllerKey;

- (void)setRevealController:(PKRevealController *)revealController
{
    objc_setAssociatedObject(self, &revealControllerKey, revealController, OBJC_ASSOCIATION_RETAIN);
}

- (PKRevealController *)revealController
{
    return (PKRevealController *)objc_getAssociatedObject(self, &revealControllerKey);
}

@end
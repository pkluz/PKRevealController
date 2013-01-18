//
//  PKRevealController+Categories.h
//  PKRevealController
//
//  Created by Philip Kluz on 12/26/12.
//  Copyright (c) 2012 zuui.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKRevealController;

@interface UIViewController (PKRevealController)

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end
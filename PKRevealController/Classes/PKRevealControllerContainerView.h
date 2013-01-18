//
//  PKRevealControllerContainerView.h
//  PKRevealController
//
//  Created by Philip Kluz on 1/16/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PKRevealControllerContainerView : UIView

#pragma mark - Methods
- (id)initForController:(UIViewController *)controller;
- (id)initForController:(UIViewController *)controller withShadow:(BOOL)hasShadow;

- (void)enableUserInteractionForContainedView;
- (void)disableUserInteractionForContainedView;
- (void)prepareForReuseWithController:(UIViewController *)controller;

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration;

@end
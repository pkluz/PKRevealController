//
//  PKRevealControllerView.m
//  PKRevealController
//
//  Created by Philip Kluz on 7/6/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "PKRevealControllerView.h"
#import "PKAnimation.h"

#define SHADOW_TRANSITION_ANIMATION_IDENTIFIER 1

static NSString *kShadowTransitionAnimationKey = @"shadowTransitionAnimation";

@implementation PKRevealControllerView

#pragma mark - Accessors

- (void)setViewController:(UIViewController *)viewController
{
    if (_viewController != viewController)
    {
        _viewController = viewController;
        _viewController.view.frame = self.bounds;
        _viewController.view.autoresizingMask = self.autoresizingMask;
    }
}

- (void)setShadow:(BOOL)shadow
{
    if (shadow)
    {
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.5;
        self.layer.shadowPath = shadowPath.CGPath;
    }
    else
    {
        self.layer.masksToBounds = YES;
        self.layer.shadowColor = nil;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowRadius = 0.0;
        self.layer.shadowPath = nil;
    }
}

#pragma mark - API

- (void)updateShadowWithAnimationDuration:(NSTimeInterval)duration
{
    UIBezierPath *existingShadowPath = [UIBezierPath bezierPathWithCGPath:self.layer.shadowPath];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    if (existingShadowPath != nil)
    {
        PKAnimation *transition = [PKAnimation animationWithKeyPath:@"shadowPath"];
        transition.fromValue = (__bridge id)(existingShadowPath.CGPath);
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = duration;
        transition.removedOnCompletion = NO;
        transition.delegate = self;
        transition.identifier = SHADOW_TRANSITION_ANIMATION_IDENTIFIER;
        
        [self.layer addAnimation:transition forKey:kShadowTransitionAnimationKey];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    if (flag && animation.identifier == SHADOW_TRANSITION_ANIMATION_IDENTIFIER)
    {
        [self setNeedsLayout];
    }
}

- (void)setUserInteractionForContainedViewEnabled:(BOOL)userInteractionEnabled
{
    [self.viewController.view setUserInteractionEnabled:userInteractionEnabled];
}

@end

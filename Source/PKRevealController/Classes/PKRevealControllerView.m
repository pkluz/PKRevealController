/*
    PKRevealController > PKRevealControllerView.m
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
    if (flag && animation.pk_identifier == SHADOW_TRANSITION_ANIMATION_IDENTIFIER)
    {
        [self setNeedsLayout];
    }
}

- (void)setUserInteractionForContainedViewEnabled:(BOOL)userInteractionEnabled
{
    [self.viewController.view setUserInteractionEnabled:userInteractionEnabled];
}

@end

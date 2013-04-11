/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#import "PKRevealControllerContainerView.h"

@interface PKRevealControllerContainerView()

@property (nonatomic, strong) UIView *leftShadowView;
@property (nonatomic, strong) UIView *rightShadowView;

@property (nonatomic, assign) CGRect previousFrame;

#pragma mark - Properties

- (void)setShadowColor:(UIColor *)color offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius forView:(UIView *)view;

@end

@implementation PKRevealControllerContainerView

#pragma mark - Initialization

- (id)initForController:(UIViewController *)controller
{
    return [self initForController:controller shadow:NO];
}

- (id)initForController:(UIViewController *)controller shadow:(BOOL)hasShadow
{
    self = [super initWithFrame:controller.view.bounds];
    
    if (self != nil)
    {
        self.viewController = controller;
        [self configureShadowViews];
        if (hasShadow) 
        {
            [self setShadowColor:[UIColor blackColor] offset:CGSizeZero opacity:0.5f radius:2.5f forRevealSide:PKRevealControllerTypeBoth];
        }
    }
    
    return self;
}

#pragma mark - Shadow

- (void)setShadowColor:(UIColor *)color
                offset:(CGSize)offset
               opacity:(CGFloat)opacity
                radius:(CGFloat)radius
         forRevealSide:(PKRevealControllerType)revealSide
{
    [self configureShadowViews];
    
    if (revealSide & PKRevealControllerTypeLeft)
    {
        [self setShadowColor:color offset:offset opacity:opacity radius:radius forView:self.leftShadowView];
    }
    if (revealSide & PKRevealControllerTypeRight)
    {
        [self setShadowColor:color offset:offset opacity:opacity radius:radius forView:self.rightShadowView];
    }
}

- (void)setShadowColor:(UIColor *)color offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius forView:(UIView *)view
{
    CALayer *layer = view.layer;
    
    if (layer != nil)
    {
        if (color != nil)
        {
            layer.masksToBounds = NO;
            layer.shadowColor = color.CGColor;
            layer.shadowOffset = offset;
            layer.shadowOpacity = opacity;
            layer.shadowRadius = radius;
            
            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
            layer.shadowPath = shadowPath.CGPath;
            
        }
        else
        {
            layer.shadowColor = nil;
            layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            layer.shadowOpacity = 0.0f;
            layer.shadowRadius = 0.0f;
            
            layer.shadowPath = nil;
            
        }
    }
}

- (void)configureShadowViews
{
    if (_leftShadowView == nil)
    {
        _leftShadowView = [[UIView alloc] initWithFrame:self.bounds];
        _leftShadowView.backgroundColor = [UIColor clearColor];
    }
    if (_rightShadowView == nil)
    {
        _rightShadowView = [[UIView alloc] initWithFrame:self.bounds];
        _rightShadowView.backgroundColor = [UIColor clearColor];
    }
    
    self.leftShadowView.frame = [self shadowBoundsForRevealSide:PKRevealControllerTypeLeft];
    self.rightShadowView.frame = [self shadowBoundsForRevealSide:PKRevealControllerTypeRight];
    
    [self insertSubview:self.leftShadowView atIndex:0];
    [self insertSubview:self.rightShadowView atIndex:0];
}

- (CGRect)shadowBoundsForRevealSide:(PKRevealControllerType)revealSide
{
    CGRect bounds = self.bounds;
    
    if (revealSide != PKRevealControllerTypeBoth)
    {
        CGFloat width = CGRectGetWidth(bounds);
        
        if (revealSide == PKRevealControllerTypeLeft)
        {
            bounds.size.width = width/2.0f;
        }
        else if (revealSide == PKRevealControllerTypeRight)
        {
            bounds.size.width = width/2.0f;
            bounds.origin.x = bounds.origin.x + width/2.0f;
        }
        else
        {
            bounds.size = CGSizeZero;
        }
        
    }
    return bounds;
}

- (BOOL)hasShadow
{
    return (self.leftShadowView.layer.shadowPath != nil || self.rightShadowView.layer.shadowPath != nil);
}

#pragma mark - Layouting

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(frame, _previousFrame)) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(containerView:didChangeFrame:)]) {
            [self.delegate containerView:self didChangeFrame:frame];
        }
        _previousFrame = frame;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self configureShadowViews];
    // layout controller view
    self.viewController.view.frame = self.viewController.view.bounds;
}

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration forView:(UIView *)view
{
    if (view.layer.shadowPath != nil)
    {
        UIBezierPath *existingShadowPath = [UIBezierPath bezierPathWithCGPath:view.layer.shadowPath];
        
        if (existingShadowPath != nil)
        {
            view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
            
            CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
            transition.fromValue = (__bridge id)(existingShadowPath.CGPath);
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.duration = duration;
            
            [view.layer addAnimation:transition forKey:@"transition"];
        }
    }
}

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration
{
    [self refreshShadowWithAnimationDuration:duration forView:self.leftShadowView];
    [self refreshShadowWithAnimationDuration:duration forView:self.rightShadowView];
}

#pragma mark - Accessors

- (void)setViewController:(UIViewController *)controller
{
    if (_viewController != controller)
    {
        [_viewController.view removeFromSuperview];
        _viewController = controller;
        _viewController.view.frame = _viewController.view.bounds;
        [self addSubview:_viewController.view];
    }
}

#pragma mark - API

- (void)enableUserInteractionForContainedView
{
    [self.viewController.view setUserInteractionEnabled:YES];
}

- (void)disableUserInteractionForContainedView
{
    [self.viewController.view setUserInteractionEnabled:NO];
}

@end
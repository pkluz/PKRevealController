//
//  PKRevealControllerContainerView.m
//  PKRevealController
//
//  Created by Philip Kluz on 1/16/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import "PKRevealControllerContainerView.h"

@interface PKRevealControllerContainerView()

#pragma mark - Properties
@property (nonatomic, weak, readwrite) UIViewController *controller;
@property (nonatomic, assign, readwrite) BOOL hasShadow;

@end

@implementation PKRevealControllerContainerView

#pragma mark - Initialization

- (id)initForController:(UIViewController *)controller
{
    self = [super initWithFrame:controller.view.bounds];
    
    if (self != nil)
    {
        self.controller = controller;
    }
    
    return self;
}

- (id)initForController:(UIViewController *)controller withShadow:(BOOL)hasShadow
{
    self = [super initWithFrame:controller.view.bounds];
    
    if (self != nil)
    {
        self.controller = controller;
        self.hasShadow = hasShadow;
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupShadow
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Accessors

- (void)setHasShadow:(BOOL)hasShadow
{
    if (_hasShadow != hasShadow)
    {
        _hasShadow = hasShadow;
        
        if (_hasShadow)
        {
            [self setupShadow];
        }
    }
}

#pragma mark - Layouting

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutControllerView];
}

- (void)layoutControllerView
{
    self.controller.view.frame = self.controller.view.bounds;
}

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration
{
    UIBezierPath *existingShadowPath = [UIBezierPath bezierPathWithCGPath:self.layer.shadowPath];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    if (existingShadowPath != nil)
    {
        CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        transition.fromValue = (__bridge id)(existingShadowPath.CGPath);
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = duration;
    
        [self.layer addAnimation:transition forKey:@"transition"];
    }
}

#pragma mark - Accessors

- (void)setController:(UIViewController *)controller
{
    if (_controller != controller)
    {
        [_controller.view removeFromSuperview];
        _controller = controller;
        _controller.view.frame = _controller.view.bounds;
        [self addSubview:_controller.view];
    }
}

#pragma mark - API

- (void)enableUserInteractionForContainedView
{
    [self.controller.view setUserInteractionEnabled:YES];
}

- (void)disableUserInteractionForContainedView
{
    [self.controller.view setUserInteractionEnabled:NO];
}

- (void)prepareForReuseWithController:(UIViewController *)controller
{
    self.controller = controller;
}

@end
//
//  PKAnimation.m
//  PKRevealController
//
//  Created by Philip Kluz on 7/3/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "PKAnimation.h"
#import "NSObject+Blocks.h"

@implementation PKAnimation

@synthesize layer = _layer;
@synthesize animating = _animating;
@synthesize key = _key;
@synthesize startHandler = _startHandler;
@synthesize completionHandler = _completionHandler;

#pragma mark - Initialization

+ (id)animation
{
    CABasicAnimation *animation = [super animation];
    animation.delegate = animation;
    return animation;
}

+ (id)animationWithKeyPath:(NSString *)path
{
    CABasicAnimation *animation = [super animationWithKeyPath:path];
    animation.delegate = animation;
    return animation;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    PKAnimation *newAnimation = [super copyWithZone:zone];
    newAnimation->_identifier = self.identifier;
    
    return newAnimation;
}

#pragma mark - PKAnimating

- (void)startAnimationOnLayer:(CALayer *)layer
{
    if (!self.isAnimating)
    {
        self.layer = layer;
        [layer addAnimation:self forKey:[self key]];
    }
}

- (void)stopAnimation
{
    [self.layer removeAnimationForKey:[self key]];
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%lu%d", (unsigned long)[self hash], self.identifier];
}

- (void)setLayer:(CALayer *)layer
{
    if (self.isAnimating)
    {
        PKLog(@"ERROR: Cannot mutate animation properties while animation is in progress.");
    }
    else
    {
        if (layer != _layer)
        {
            _layer = layer;
        }
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CABasicAnimation *)animation
{
    self.animating = YES;
    
    [self performBlock:^
    {
        if (self.startHandler)
        {
            self.startHandler();
        }
    }
    onMainThread:YES];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    self.animating = NO;
    
    [self performBlock:^
    {
        if (self.completionHandler)
        {
            self.completionHandler(flag);
        }
    }
    onMainThread:YES];
}

@end

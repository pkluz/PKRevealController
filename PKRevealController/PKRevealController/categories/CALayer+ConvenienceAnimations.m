//
//  CALayer+ConvenienceAnimations.m
//  PKRevealController
//
//  Created by Philip Kluz on 6/30/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "CALayer+ConvenienceAnimations.h"

@implementation CALayer (ConvenienceAnimations)

#pragma mark - Methods

+ (CABasicAnimation *)animationFromAlpha:(CGFloat)fromValue
                                 toAlpha:(CGFloat)toValue
                          timingFunction:(CAMediaTimingFunction *)timingFunction
                                duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.timingFunction = timingFunction;

    animation.duration = duration;    
    return animation;
}

+ (CABasicAnimation *)animationFromTransformation:(CATransform3D)fromTransformation
                                 toTransformation:(CATransform3D)toTransformation
                                   timingFunction:(CAMediaTimingFunction *)timingFunction
                                         duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:fromTransformation];
    animation.toValue = [NSValue valueWithCATransform3D:toTransformation];
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    return animation;
}

+ (CABasicAnimation *)animationFromPosition:(CGPoint)fromPosition
                                 toPosition:(CGPoint)toPosition
                             timingFunction:(CAMediaTimingFunction *)timingFunction
                                   duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    animation.toValue = [NSValue valueWithCGPoint:toPosition];
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    return animation;
}

- (void)animateToAlpha:(CGFloat)value
        timingFunction:(CAMediaTimingFunction *)timingFunction
              duration:(NSTimeInterval)duration
            alterModel:(BOOL)alterModel
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:self.opacity];
    animation.toValue = [NSNumber numberWithFloat:value];
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    if (alterModel)
    {
        self.opacity = value;
    }
    
    [self addAnimation:animation forKey:@"opacity"];
}

- (void)animateToTransform:(CATransform3D)toTransform
            timingFunction:(CAMediaTimingFunction *)timingFunction
                  duration:(NSTimeInterval)duration
                alterModel:(BOOL)alterModel
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:[(CALayer *)[self presentationLayer] transform]];
    animation.toValue = [NSValue valueWithCATransform3D:toTransform];
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    if (alterModel)
    {
        self.transform = toTransform;
    }
    
    [self addAnimation:animation forKey:@"transform"];
}

- (void)animateToPoint:(CGPoint)toPoint
        timingFunction:(CAMediaTimingFunction *)timingFunction
              duration:(NSTimeInterval)duration
            alterModel:(BOOL)alterModel
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:((CALayer *)self.presentationLayer).position];
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    if (alterModel)
    {
        self.position = toPoint;
    }
    
    [self addAnimation:animation forKey:@"position"];
}

@end

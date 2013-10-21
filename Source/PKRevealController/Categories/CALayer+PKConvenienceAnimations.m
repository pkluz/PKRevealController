/*
    PKRevealController > CALayer+PKConvenienceAnimations.m
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

#import "CALayer+PKConvenienceAnimations.h"

@implementation CALayer (PKConvenienceAnimations)

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

/*
    PKRevealController > PKSequentialAnimation.m
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

#import "PKSequentialAnimation.h"
#import "NSObject+PKBlocks.h"

@interface PKSequentialAnimation ()

#pragma mark - Properties
@property (nonatomic, strong, readwrite) NSArray *animations;

@end

@implementation PKSequentialAnimation

@synthesize layer = _layer;
@synthesize animating = _animating;
@synthesize key = _key;
@synthesize startHandler = _startHandler;
@synthesize completionHandler = _completionHandler;

+ (instancetype)animationForKeyPath:(NSString *)keyPath
                             values:(NSArray *)values
                           duration:(NSTimeInterval)duration
{
    return [self animationForKeyPath:keyPath
                              values:values
                            duration:duration
                            progress:nil
                          completion:nil];
}

+ (instancetype)animationForKeyPath:(NSString *)keyPath
                             values:(NSArray *)values
                           duration:(NSTimeInterval)duration
                           progress:(PKSequentialAnimationProgressBlock)progress
                         completion:(PKAnimationCompletionBlock)completion
{
    PKSequentialAnimation *animation = [[PKSequentialAnimation alloc] init];
    
    animation.animations = [animation animationsForKeyPath:keyPath withValues:values duration:duration];
    animation.completionHandler = completion;
    animation.progressHandler = progress;
    
    return animation;
}

- (NSArray *)animationsForKeyPath:(NSString *)keyPath
                       withValues:(NSArray *)values
                         duration:(NSTimeInterval)duration
{
    NSMutableArray *animations = [NSMutableArray arrayWithCapacity:[values count]];
    
    [values enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop)
     {
         PKAnimation *animation = [PKAnimation animationWithKeyPath:keyPath];
         animation.fromValue = [((CALayer *)self.layer.presentationLayer) valueForKeyPath:keyPath];
         animation.toValue = value;
         animation.duration = duration / [values count];
         animation.timingFunction = [self timingFunctionForAnimationAtIndex:index totalNumberOfAnimations:[values count]];
         animation.identifier = index;
         animation.delegate = self;
         
         [animations addObject:animation];
     }];
    
    return [animations copy];
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[self hash]];
}

- (NSString *)keyForAnimationAtIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%@%@", self.key, [(PKAnimation *)self.animations[index] key]];
}

- (void)startAnimationOnLayer:(CALayer *)layer
{
    if (!self.isAnimating && [self.animations count] > 0)
    {
        self.layer = layer;
        PKAnimation *firstAnimation = self.animations[0];
        firstAnimation.fromValue = [self.layer valueForKeyPath:firstAnimation.keyPath];
        
        [self.layer setValue:firstAnimation.toValue forKey:firstAnimation.keyPath];
        [self.layer addAnimation:firstAnimation forKey:[self keyForAnimationAtIndex:0]];
    }
}

- (void)stopAnimation
{
    CALayer *presentationLayer = (CALayer *)self.layer.presentationLayer;
    
    NSArray *animationKeys = [self.layer.animationKeys copy];
    
    [animationKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         CAAnimation *animation = [self.layer animationForKey:key];
         
         if ([animation isMemberOfClass:[PKAnimation class]] &&
             [key hasPrefix:self.key])
         {
             PKAnimation *animation = (PKAnimation *)[self.layer animationForKey:key];
             [self.layer setValue:[presentationLayer valueForKeyPath:animation.keyPath] forKeyPath:animation.keyPath];
             [self.layer removeAnimationForKey:key];
         }
     }];
}

- (CAMediaTimingFunction *)timingFunctionForAnimationAtIndex:(NSUInteger)index totalNumberOfAnimations:(NSUInteger)total
{
    CAMediaTimingFunction *function = nil;
    
    if (total == 1)
    {
        function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    else if (total == 2)
    {
        if (index == 0)
        {
            function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        }
        else
        {
            function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        }
    }
    else
    {
        if (index == 0)
        {
            function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        }
        else if ((index + 1) == total)
        {
            function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        }
        else
        {
            function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        }
    }
    
    return function;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    self.animating = YES;
    
    PKAnimation *animation = self.animations[anim.pk_identifier];
    
    [self pk_performBlock:^
    {
        if (self.progressHandler)
        {
            self.progressHandler(animation.fromValue, animation.toValue, animation.identifier);
        }
    }
    onMainThread:YES];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSInteger currentIndex = anim.pk_identifier;
    NSInteger lastAnimationIndex = [self.animations count] - 1;
    
    if (flag && currentIndex < lastAnimationIndex)
    {
        NSUInteger nextAnimationIndex = currentIndex + 1;
        
        NSString *nextAnimationIndexString = [NSString stringWithFormat:@"%lu", (unsigned long)nextAnimationIndex];
        PKAnimation *nextAnimation = self.animations[nextAnimationIndex];
        nextAnimation.fromValue = [((CALayer *)self.layer.presentationLayer) valueForKeyPath:nextAnimation.keyPath];
        
        [self pk_performBlock:^
        {
            if (self.progressHandler)
            {
                self.progressHandler(nextAnimation.fromValue,
                                     nextAnimation.toValue,
                                     nextAnimationIndex);
            }
        }
        onMainThread:YES];
        
        [self.layer setValue:nextAnimation.toValue forKeyPath:nextAnimation.keyPath];
        [self.layer addAnimation:nextAnimation forKey:nextAnimationIndexString];
    }
    else
    {
        self.animating = NO;
        [self stopAnimation];
        
        [self pk_performBlock:^
        {
            if (self.completionHandler)
            {
                self.completionHandler(flag);
            }
        }
        onMainThread:YES];
    }
}

@end

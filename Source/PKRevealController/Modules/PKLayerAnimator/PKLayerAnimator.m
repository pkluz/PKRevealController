/*
    PKRevealController > PKLayerAnimator.m
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

#import "PKLayerAnimator.h"
#import "CALayer+PKConvenienceAnimations.h"
#import "NSObject+PKBlocks.h"

@interface PKLayerAnimator ()

#pragma mark - Properties
@property (nonatomic, strong, readwrite) CALayer *layer;
@property (nonatomic, strong, readwrite) NSMutableDictionary *animations;

@end

@implementation PKLayerAnimator

#pragma mark - Initialization

+ (instancetype)animatorForLayer:(CALayer *)layer
{
    return [[[self class] alloc] initWithLayer:layer];
}

- (instancetype)initWithLayer:(CALayer *)layer
{
    self = [super init];
    
    if (self)
    {
        self.layer = layer;
        self.animations = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - API

- (void)addAnimation:(PKAnimation *)animation forKey:(NSString *)key
{
    [self.animations setObject:animation forKey:key];
}

- (void)addSequentialAnimation:(PKSequentialAnimation *)animation forKey:(NSString *)key
{
    [self.animations setObject:animation forKey:key];
}

- (void)startAnimationForKey:(NSString *)key
{
    id<PKAnimating> animation = [self.animations objectForKey:key];
    [animation startAnimationOnLayer:self.layer];
}

- (void)stopAnimationForKey:(NSString *)key
{
    id<PKAnimating> animation = [self.animations objectForKey:key];
    [animation stopAnimation];
}

- (void)stopAndRemoveAllAnimations
{
    @synchronized (self)
    {
        for (NSString *key in self.animations.keyEnumerator)
        {
            [self stopAnimationForKey:key];
        }
        
        [self.animations removeAllObjects];
    }
}

@end

//
//  PKLayerAnimator..m
//  PKRevealController
//
//  Created by Philip Kluz on 6/29/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "PKLayerAnimator.h"
#import "CALayer+ConvenienceAnimations.h"
#import "NSObject+Blocks.h"

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

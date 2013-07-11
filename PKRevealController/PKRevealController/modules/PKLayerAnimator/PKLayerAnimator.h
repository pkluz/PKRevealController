//
//  PKLayerAnimator.h
//  PKRevealController
//
//  Created by Philip Kluz on 6/29/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PKAnimation.h"
#import "PKSequentialAnimation.h"

@interface PKLayerAnimator : NSObject

#pragma mark - Properties
@property (nonatomic, strong, readonly) CALayer *layer;

#pragma mark - Methods
+ (instancetype)animatorForLayer:(CALayer *)layer;

- (void)addAnimation:(PKAnimation *)animation forKey:(NSString *)key;
- (void)addSequentialAnimation:(PKSequentialAnimation *)animation forKey:(NSString *)key;

- (void)startAnimationForKey:(NSString *)key;
- (void)stopAnimationForKey:(NSString *)key;
- (void)stopAndRemoveAllAnimations;


@end

//
//  PKSequentialAnimation.h
//  PKRevealController
//
//  Created by Philip Kluz on 7/2/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "PKAnimation.h"
#import "PKAnimating.h"

typedef void(^PKSequentialAnimationProgressBlock)(NSValue *fromValue, NSValue *toValue, NSUInteger index);

@interface PKSequentialAnimation : NSObject <PKAnimating>

#pragma mark - Properties
@property (nonatomic, copy, readwrite) PKSequentialAnimationProgressBlock progressHandler;

#pragma mark - Methods
+ (instancetype)animationForKeyPath:(NSString *)keyPath
                             values:(NSArray *)values
                           duration:(NSTimeInterval)duration;

+ (instancetype)animationForKeyPath:(NSString *)keyPath
                             values:(NSArray *)values
                           duration:(NSTimeInterval)duration
                           progress:(PKSequentialAnimationProgressBlock)progress
                         completion:(PKAnimationCompletionBlock)completion;

@end

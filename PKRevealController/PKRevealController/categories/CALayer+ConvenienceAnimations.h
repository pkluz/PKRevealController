//
//  CALayer+ConvenienceAnimations.h
//  PKRevealController
//
//  Created by Philip Kluz on 6/30/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (ConvenienceAnimations)

#pragma mark - Methods

+ (CABasicAnimation *)animationFromAlpha:(CGFloat)fromValue
                                 toAlpha:(CGFloat)toValue
                          timingFunction:(CAMediaTimingFunction *)timingFunction
                                duration:(NSTimeInterval)duration;

+ (CABasicAnimation *)animationFromTransformation:(CATransform3D)fromTransformation
                                 toTransformation:(CATransform3D)toTransformation
                                   timingFunction:(CAMediaTimingFunction *)timingFunction
                                         duration:(NSTimeInterval)duration;


+ (CABasicAnimation *)animationFromPosition:(CGPoint)fromPosition
                                 toPosition:(CGPoint)toPosition
                             timingFunction:(CAMediaTimingFunction *)timingFunction
                                   duration:(NSTimeInterval)duration;

- (void)animateToAlpha:(CGFloat)value
        timingFunction:(CAMediaTimingFunction *)timingFunction
              duration:(NSTimeInterval)duration
            alterModel:(BOOL)alterModel;

- (void)animateToTransform:(CATransform3D)toTransform
            timingFunction:(CAMediaTimingFunction *)timingFunction
                  duration:(NSTimeInterval)duration
                alterModel:(BOOL)alterModel;

- (void)animateToPoint:(CGPoint)toPoint
        timingFunction:(CAMediaTimingFunction *)timingFunction
              duration:(NSTimeInterval)duration
            alterModel:(BOOL)alterModel;

@end

//
//  PKAnimating.h
//  PKRevealController
//
//  Created by Philip Kluz on 7/7/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAAnimation+Identifier.h"

typedef void(^PKAnimationStartBlock)();
typedef void(^PKAnimationCompletionBlock)(BOOL finished);

@protocol PKAnimating <NSObject>

@required

#pragma mark - Properties
@property (nonatomic, weak, readwrite) CALayer *layer;
@property (nonatomic, assign, readwrite, getter = isAnimating) BOOL animating;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readwrite) PKAnimationStartBlock startHandler;
@property (nonatomic, copy, readwrite) PKAnimationCompletionBlock completionHandler;

#pragma mark - Methods
- (void)startAnimationOnLayer:(CALayer *)layer;
- (void)stopAnimation;

@end

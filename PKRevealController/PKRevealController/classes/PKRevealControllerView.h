//
//  PKRevealControllerView.h
//  PKRevealController
//
//  Created by Philip Kluz on 7/6/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PKRevealControllerView : UIView

#pragma mark - Properties
@property (nonatomic, assign, readwrite, getter = hasShadow) BOOL shadow;
@property (nonatomic, weak, readwrite) UIViewController *viewController;

#pragma mark - Methods
- (void)updateShadowWithAnimationDuration:(NSTimeInterval)duration;
- (void)setUserInteractionForContainedViewEnabled:(BOOL)userInteractionEnabled;

@end

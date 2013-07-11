//
//  PKAnimation.h
//  PKRevealController
//
//  Created by Philip Kluz on 7/3/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PKAnimating.h"

@interface PKAnimation : CABasicAnimation <PKAnimating>

#pragma mark - Properties
@property (nonatomic, assign, readwrite) NSInteger identifier;

@end

/* 
 
 Copyright (c) 2011, zuui.org (Philip Kluz)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of zuui.org nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL ZUUI.ORG BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

/*
 * NOTE: Before editing the values below make sure they make 'sense'. Unexpected behavior might occur if for instance the 'REVEAL_EDGE'
 *		 were to be lower than the left trigger level...
 */

// 'REVEAL_EDGE' defines the point on the x-axis up to which the rear view is shown.
#define REVEAL_EDGE 260.0f

// 'REVEAL_EDGE_OVERDRAW' defines the maximum offset that can occur after the 'REVEAL_EDGE' has been reached.
#define REVEAL_EDGE_OVERDRAW 60.0f

// 'REVEAL_VIEW_TRIGGER_LEVEL_LEFT' defines the least amount of offset that needs to be panned until the front view snaps to the right edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_LEFT 125.0f

// 'REVEAL_VIEW_TRIGGER_LEVEL_RIGHT' defines the least amount of translation that needs to be panned until the front view snaps _BACK_ to the left edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_RIGHT 200.0f

// 'VELOCITY_REQUIRED_FOR_QUICK_FLICK' is the minimum speed of the finger required to instantly trigger a reveal/hide.
#define VELOCITY_REQUIRED_FOR_QUICK_FLICK 1300.0f

// Required for the shadow cast by the front view.
#import <QuartzCore/QuartzCore.h>

#import "ZUUIRevealController.h"
#import "FrontViewController.h"
#import "RearViewController.h"

@interface ZUUIRevealController()

// Private Properties:
@property (assign, nonatomic) float previousPanOffset;
@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;

// Private Methods:
- (CGFloat)calculateOffsetForTranslationInView:(CGFloat)x;

@end

@implementation ZUUIRevealController

@synthesize previousPanOffset;
@synthesize currentFrontViewPosition;

@synthesize frontViewController;
@synthesize rearViewController;
@synthesize frontView;
@synthesize rearView;

#pragma mark - Initialization

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		self = [super initWithNibName:@"ZUUIRevealController_iPhone" bundle:nil];
	}
	else
	{
		self = [super initWithNibName:@"ZUUIRevealController_iPad" bundle:nil];
	}
	
    if (nil != self)
    {
        self.frontViewController = aFrontViewController;
        self.rearViewController = aBackViewController;
		
		if ([self conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)] && [self.frontViewController isKindOfClass:[FrontViewController class]])
		{
			((FrontViewController *)self.frontViewController).delegate = self;
		}
		else
		{
			return nil;
		}
    }
	
    return self;
}

#pragma mark - ZUUIRevealViewControllerDelegate Protocol

- (void)delegateRecognizedPanGesture:(UIPanGestureRecognizer *)recognizer
{
	// Case - Pan input ended.
	if (UIGestureRecognizerStateEnded == [recognizer state])
	{
		// Case - Quick finger flick fast enough to cause instant change:
		if (fabs([recognizer velocityInView:self.view].x) > VELOCITY_REQUIRED_FOR_QUICK_FLICK)
		{
			if ([recognizer velocityInView:self.view].x > 0.0f)
			{
				[UIView animateWithDuration:0.15f animations:^
				{
					self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				}];
			}
			else
			{
				[UIView animateWithDuration:0.15f animations:^
				{
					self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				}];
			}
		}
		
		// Case - Slow pan/drag ended:
		else
		{
			float dynamicTriggerLevel = (FrontViewPositionLeft == self.currentFrontViewPosition) ? REVEAL_VIEW_TRIGGER_LEVEL_LEFT : REVEAL_VIEW_TRIGGER_LEVEL_RIGHT;
			
			if (self.frontView.frame.origin.x >= dynamicTriggerLevel && self.frontView.frame.origin.x != REVEAL_EDGE)
			{
				[UIView animateWithDuration:0.15f animations:^
				{
					self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				}];
			}
			else if (self.frontView.frame.origin.x < dynamicTriggerLevel && self.frontView.frame.origin.x != 0.0f)
			{
				[UIView animateWithDuration:0.15f animations:^
				{
					self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				}];
			}
		}
		
		// Now adjust the current state enum.
		if (self.frontView.frame.origin.x == 0.0f)
		{
			self.currentFrontViewPosition = FrontViewPositionLeft;
		}
		else
		{
			self.currentFrontViewPosition = FrontViewPositionRight;
		}
		return;
	}
	
	// Case - Slow pan/drag in progress from either the left or the right:
	if (FrontViewPositionLeft == self.currentFrontViewPosition)
	{
		if ([recognizer translationInView:self.view].x < 0.0f)
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else
		{
			float offset = [self calculateOffsetForTranslationInView:[recognizer translationInView:self.view].x];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
	else
	{
		if ([recognizer translationInView:self.view].x > 0.0f)
		{
			float offset = [self calculateOffsetForTranslationInView:([recognizer translationInView:self.view].x+REVEAL_EDGE)];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else if ([recognizer translationInView:self.view].x > -REVEAL_EDGE)
		{
			self.frontView.frame = CGRectMake([recognizer translationInView:self.view].x+REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
}

- (void)delegateRequestedToToggleReveal:(id)sender
{
	if (FrontViewPositionLeft == self.currentFrontViewPosition)
	{
		[UIView animateWithDuration:0.25f animations:^
		{
			self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}];
		
		self.currentFrontViewPosition = FrontViewPositionRight;
	}
	else
	{
		[UIView animateWithDuration:0.25f animations:^
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}];
		
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
}

#pragma mark - Helper

/*
 * Note: If someone wants to bother to implement a better (smoother) function. Go for it and share!
 */
- (CGFloat)calculateOffsetForTranslationInView:(CGFloat)x
{
	CGFloat result;
	
	if (x <= REVEAL_EDGE)
	{
		// Translate linearly.
		result = x;
	}
	else if (x <= REVEAL_EDGE+(M_PI*REVEAL_EDGE_OVERDRAW/2.0f))
	{
		// and eventually slow translation slowly.
		result = REVEAL_EDGE_OVERDRAW*sin((x-REVEAL_EDGE)/REVEAL_EDGE_OVERDRAW)+REVEAL_EDGE;
	}
	else
	{
		// ...until we hit the limit.
		result = REVEAL_EDGE+REVEAL_EDGE_OVERDRAW;
	}
	
	return result;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.frontView.bounds];
	self.frontView.layer.masksToBounds = NO;
	self.frontView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.frontView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.frontView.layer.shadowOpacity = 1.0f;
	self.frontView.layer.shadowRadius = 2.5f;
	self.frontView.layer.shadowPath = shadowPath.CGPath;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Init the position with only the front view visible.
	self.previousPanOffset = 0.0f;
	self.currentFrontViewPosition = FrontViewPositionLeft;
	
	// Add the rear view controller to the hierarchy.
	[self addChildViewController:self.rearViewController];
    [self.rearView addSubview:self.rearViewController.view];
    [self.rearViewController didMoveToParentViewController:self];
	
	// Add the front view controller to the hierarchy.
	[self addChildViewController:self.frontViewController];
    [self.frontView addSubview:self.frontViewController.view];
    [self.frontViewController didMoveToParentViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// Remove the rear view controller from the hierarchy.
    [self.rearViewController.view removeFromSuperview];
    [self.rearViewController removeFromParentViewController];
	
	// Remove the front view controller from the hierarchy.
    [self.frontViewController.view removeFromSuperview];
    [self.frontViewController removeFromParentViewController];
	
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Memory Management

- (void)dealloc
{
	[frontViewController release], self.frontViewController = nil;
	[rearViewController release], self.rearViewController = nil;
	[frontView release], self.frontView = nil;
	[rearView release], self.rearView = nil;
	
	[super dealloc];
}

@end
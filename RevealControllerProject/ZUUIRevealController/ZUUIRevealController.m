/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
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

@interface ZUUIRevealController()

// Private Properties:
@property (retain, nonatomic) UIView *frontView;
@property (retain, nonatomic) UIView *rearView;
@property (assign, nonatomic) float previousPanOffset;
@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;

// Private Methods:
- (CGFloat)calculateOffsetForTranslationInView:(CGFloat)x;

@end

@implementation ZUUIRevealController

@synthesize previousPanOffset = _previousPanOffset;
@synthesize currentFrontViewPosition = _currentFrontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize frontView = _frontView;
@synthesize rearView = _rearView;
@synthesize delegate = _delegate;

#pragma mark - Initialization

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController
{
	self = [super init];
	
	if (nil != self)
	{
		self.frontViewController = aFrontViewController;
		self.rearViewController = aBackViewController;
	}
	
	return self;
}

#pragma mark - Reveal Callbacks

// Slowly reveal or hide the rear view based on the translation of the finger.
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer
{	
	// 1. Ask the delegate (if appropriate) if we are allowed to do the particular interaction:
	if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)])
	{
		// Case a): We're going to be revealing since we're hidden now.
		if (FrontViewPositionLeft == self.currentFrontViewPosition)
		{
			if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
			{
				if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController])
				{
					return;
				}
			}
		}
		// Case b): We're going to be hiding, since we're revealed now.
		else
		{
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
			{
				if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController])
				{
					return;
				}
			}
		}
	}
	
	// 2. Now that we've know we're here, we check whether we're just about to _START_ an interaction,...
	if (UIGestureRecognizerStateBegan == [recognizer state])
	{
		// Check if a delegate exists
		if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)])
		{
			// Determine whether we're going to be revealing or hiding.
			if (FrontViewPositionLeft == self.currentFrontViewPosition)
			{
				if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
				{
					[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
				}
			}
			else
			{
				if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
				{
					[self.delegate revealController:self willHideRearViewController:self.rearViewController];
				}
			}
		}
	}
	
	// 3. ...or maybe the interaction already _ENDED_?
	if (UIGestureRecognizerStateEnded == [recognizer state])
	{
		// Case a): Quick finger flick fast enough to cause instant change:
		if (fabs([recognizer velocityInView:self.view].x) > VELOCITY_REQUIRED_FOR_QUICK_FLICK)
		{
			if ([recognizer velocityInView:self.view].x > 0.0f)
			{				
				[UIView animateWithDuration:0.15f animations:^
				 {
					 self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				 }
				completion:^(BOOL finished)
				 {
					 // Dispatch message to delegate, telling it the 'rearView' _DID_ reveal, if appropriate:
					 if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
					 {
						 [self.delegate revealController:self didRevealRearViewController:self.rearViewController];
					 }
				 }];
			}
			else
			{
				[UIView animateWithDuration:0.15f animations:^
				 {
					 self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				 }
				 completion:^(BOOL finished)
				 {
					 // Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
					 if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
					 {
						 [self.delegate revealController:self didHideRearViewController:self.rearViewController];
					 }
				 }];
			}
		}
		// Case b) Slow pan/drag ended:
		else
		{
			float dynamicTriggerLevel = (FrontViewPositionLeft == self.currentFrontViewPosition) ? REVEAL_VIEW_TRIGGER_LEVEL_LEFT : REVEAL_VIEW_TRIGGER_LEVEL_RIGHT;
			
			if (self.frontView.frame.origin.x >= dynamicTriggerLevel && self.frontView.frame.origin.x != REVEAL_EDGE)
			{
				[UIView animateWithDuration:0.15f animations:^
				 {
					 self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				 }
				 completion:^(BOOL finished)
				 {
					 // Dispatch message to delegate, telling it the 'rearView' _DID_ reveal, if appropriate:
					 if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
					 {
						 [self.delegate revealController:self didRevealRearViewController:self.rearViewController];
					 }
				 }];
			}
			else if (self.frontView.frame.origin.x < dynamicTriggerLevel && self.frontView.frame.origin.x != 0.0f)
			{
				[UIView animateWithDuration:0.15f animations:^
				 {
					 self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				 }
				 completion:^(BOOL finished)
				 {
					 // Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
					 if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
					 {
						 [self.delegate revealController:self didHideRearViewController:self.rearViewController];
					 }
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
	
	// 4. None of the above? That means it's _IN PROGRESS_!
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

// Instantaneously toggle the rear view's visibility.
- (void)revealToggle:(id)sender
{	
	if (FrontViewPositionLeft == self.currentFrontViewPosition)
	{ 
		// Check if a delegate exists and if so, whether it is fine for us to revealing the rear view.
		if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
		{
			if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController])
			{
				return;
			}
		}
		
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ reveal, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
		{
			[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
		}
		
		[UIView animateWithDuration:0.25f animations:^
		 {
			 self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		 }
		 completion:^(BOOL finished)
		 {
			 // Dispatch message to delegate, telling it the 'rearView' _DID_ reveal, if appropriate:
			 if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
			 {
				 [self.delegate revealController:self didRevealRearViewController:self.rearViewController];
			 }
		 }];
		
		self.currentFrontViewPosition = FrontViewPositionRight;
	}
	else
	{
		// Check if a delegate exists and if so, whether it is fine for us to hiding the rear view.
		if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
		{
			if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController])
			{
				return;
			}
		}
		
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ hide, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
		{
			[self.delegate revealController:self willHideRearViewController:self.rearViewController];
		}
		
		[UIView animateWithDuration:0.25f animations:^
		 {
			 self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		 }
		 completion:^(BOOL finished)
		 {
			 // Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
			 if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
			 {
				 [self.delegate revealController:self didHideRearViewController:self.rearViewController];
			 }
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
	
	self.frontView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.rearView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	
	self.frontView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.rearView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:self.rearView];
	[self.view addSubview:self.frontView];
	
	/* Create a fancy shadow aroung the frontView.
	 *
	 * Note: UIBezierPath needed because shadows are evil. If you don't use the path, you might not
	 * not notice a difference at first, but the keen eye will (even on an iPhone 4S) observe that 
	 * the interface rotation _WILL_ lag slightly and feel less fluid than with the path.
	 */
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.frontView.bounds];
	self.frontView.layer.masksToBounds = NO;
	self.frontView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.frontView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.frontView.layer.shadowOpacity = 1.0f;
	self.frontView.layer.shadowRadius = 2.5f;
	self.frontView.layer.shadowPath = shadowPath.CGPath;
}

- (void)viewDidUnload
{
    // release views as they will be repopulated in viewDidLoad/viewWillAppear
    self.frontView = nil;
    self.rearView = nil;
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
	[super viewDidDisappear:animated];
	
	// Remove the rear view controller from the hierarchy.
	[self.rearViewController.view removeFromSuperview];
	[self.rearViewController removeFromParentViewController];
	
	// Remove the front view controller from the hierarchy.
	[self.frontViewController.view removeFromSuperview];
	[self.frontViewController removeFromParentViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Memory Management

- (void)dealloc
{
	[_frontViewController release], _frontViewController = nil;
	[_rearViewController release], _rearViewController = nil;
	[_frontView release], _frontView = nil;
	[_rearView release], _rearView = nil;

	[super dealloc];
}

@end

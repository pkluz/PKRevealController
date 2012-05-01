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
 *		 were to be lower than the top/left trigger level...
 */

#define REVEAL_VERTICAL 1

// 'REVEAL_EDGE' defines the point on the x-axis up to which the rear view is shown.
#define REVEAL_EDGE 160.0f

// 'REVEAL_EDGE_OVERDRAW' defines the maximum offset that can occur after the 'REVEAL_EDGE' has been reached.
#define REVEAL_EDGE_OVERDRAW 60.0

// 'REVEAL_VIEW_TRIGGER_LEVEL_BOTTOM_RIGHT' defines the least amount of offset that needs to be panned until the front view snaps to the right/bottom edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_BOTTOM_RIGHT 40.0f

// 'REVEAL_VIEW_TRIGGER_LEVEL_TOP_LEFT' defines the least amount of translation that needs to be panned until the front view snaps _BACK_ to the left/top edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_TOP_LEFT 120.0f

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

// Private Methods:
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x;
- (void)_revealAnimation;
- (void)_concealAnimation;

- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController;
- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController;
- (void)_removeViewControllerFromHierarchy:(UIViewController *)frontViewController;

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animated:(BOOL)animated;

// Work in progress:
// - (void)_performRearViewControllerSwap:(UIViewController *)newRearViewController;
// - (void)setRearViewController:(UIViewController *)rearViewController; // Delegate Call.

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
		_frontViewController = [aFrontViewController retain];
		_rearViewController = [aBackViewController retain];
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
		// Case a): We're going to be revealing.
		if (FrontViewPositionTopLeft == self.currentFrontViewPosition)
		{
			if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
			{
				if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController])
				{
					return;
				}
			}
		}
		// Case b): We're going to be concealing.
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
			if (FrontViewPositionTopLeft == self.currentFrontViewPosition)
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
        
        float velocityInView = REVEAL_VERTICAL ? [recognizer velocityInView:self.view].y : [recognizer velocityInView:self.view].x;
        
		// Case a): Quick finger flick fast enough to cause instant change:
		if (fabs(velocityInView) > VELOCITY_REQUIRED_FOR_QUICK_FLICK)
		{
			if (velocityInView > 0.0f)
			{				
				[self _revealAnimation];
			}
			else
			{
				[self _concealAnimation];
			}
		}
		// Case b) Slow pan/drag ended:
		else
		{
			float dynamicTriggerLevel = (FrontViewPositionTopLeft == self.currentFrontViewPosition) ? REVEAL_VIEW_TRIGGER_LEVEL_BOTTOM_RIGHT : REVEAL_VIEW_TRIGGER_LEVEL_TOP_LEFT;
			
            float origin = REVEAL_VERTICAL ? self.frontView.frame.origin.y : self.frontView.frame.origin.x; 
            
			if (origin >= dynamicTriggerLevel && origin != REVEAL_EDGE)
			{
				[self _revealAnimation];
			}
			else if (origin < dynamicTriggerLevel && origin != 0.0f)
			{
				[self _concealAnimation];
			}
		}
        
        float origin = REVEAL_VERTICAL ? self.frontView.frame.origin.y : self.frontView.frame.origin.x; 
		
		// Now adjust the current state enum.
		if (origin == 0.0f)
		{
			self.currentFrontViewPosition = FrontViewPositionTopLeft;
		}
		else
		{
			self.currentFrontViewPosition = FrontViewPositionBottomRight;
		}
		
		return;
	}
    
    float translationInView = REVEAL_VERTICAL ? [recognizer translationInView:self.view].y : [recognizer translationInView:self.view].x; 
	
	// 4. None of the above? That means it's _IN PROGRESS_!
	if (FrontViewPositionTopLeft == self.currentFrontViewPosition)
	{
        
		if (translationInView < 0.0f)
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else
		{
			float offset_x = REVEAL_VERTICAL ? 0.0f : [self _calculateOffsetForTranslationInView:translationInView];
            float offset_y = REVEAL_VERTICAL ? [self _calculateOffsetForTranslationInView:translationInView] : 0.0f;
			self.frontView.frame = CGRectMake(offset_x, offset_y, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
	else
	{
		if (translationInView > 0.0f)
		{
			float offset_x = REVEAL_VERTICAL ? 0.0f : [self _calculateOffsetForTranslationInView:translationInView+REVEAL_EDGE];
            float offset_y = REVEAL_VERTICAL ? [self _calculateOffsetForTranslationInView:translationInView+REVEAL_EDGE] : 0.0f;
			self.frontView.frame = CGRectMake(offset_x, offset_y, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else if ([recognizer translationInView:self.view].y > -REVEAL_EDGE)
		{
            float offset_x = REVEAL_VERTICAL ? 0.0f : translationInView+REVEAL_EDGE;
            float offset_y = REVEAL_VERTICAL ? translationInView+REVEAL_EDGE : 0.0f;
            self.frontView.frame = CGRectMake(offset_x, offset_y, self.frontView.frame.size.width, self.frontView.frame.size.height);
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
	if (FrontViewPositionTopLeft == self.currentFrontViewPosition)
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
		
		[self _revealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionBottomRight;
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
		
		[self _concealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionTopLeft;
	}
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
	[self setFrontViewController:frontViewController animated:NO];
}

- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated
{
	if (nil != frontViewController && _frontViewController == frontViewController)
	{
		[self revealToggle:nil];
	}
	else if (nil != frontViewController)
	{
		[self _swapCurrentFrontViewControllerWith:frontViewController animated:animated];
	}
}

/*
 // This code is experimental. It works but is not recommended for usage yet.
- (void)setRearViewController:(UIViewController *)rearViewController
{
	if (nil != rearViewController)
	{
		if (self.currentFrontViewPosition == FrontViewPositionBottomRight)
		{
			[UIView animateWithDuration:0.25f animations:^
			{
				self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			}
			completion:^(BOOL finished)
			{
				[self _performRearViewControllerSwap:rearViewController];
				[self _revealAnimation];
			}];
		}
		else
		{
			[self _performRearViewControllerSwap:rearViewController];
		}
	}
}
*/

#pragma mark - Helper

- (void)_revealAnimation
{	
	[UIView animateWithDuration:0.25f animations:^
	{
        float offset_x = REVEAL_VERTICAL ? 0.0f : REVEAL_EDGE;
        float offset_y = REVEAL_VERTICAL ? REVEAL_EDGE : 0.0f;
		self.frontView.frame = CGRectMake(offset_x, offset_y, self.frontView.frame.size.width, self.frontView.frame.size.height);
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

- (void)_concealAnimation
{	
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
}

/*
 * Note: If someone wants to bother to implement a better (smoother) function. Go for it and share!
 */
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x
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

/*
// This code is experimental. It works but is not recommended for usage yet.
- (void)_performRearViewControllerSwap:(UIViewController *)newRearViewController
{
	[self _removeRearViewControllerFromHierarchy:self.rearViewController];
	
	[_rearViewController release];
	_rearViewController = [newRearViewController retain];
	
	[self _addRearViewControllerToHierarchy:newRearViewController];
}
*/

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(revealController:willSwapToFrontViewController:)])
	{
		[self.delegate revealController:self willSwapToFrontViewController:newFrontViewController];
	}
	
	CGFloat xSwapOffset = 0.0f;
	CGFloat ySwapOffset = 0.0f;
	
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		xSwapOffset = REVEAL_VERTICAL ? 0.0f : 40.0f;
		ySwapOffset = REVEAL_VERTICAL ? 40.0f : 0.0f;
	}
	
	if (animated)
	{
		[UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^
		{
			CGRect offsetRect = CGRectOffset(self.frontView.frame, xSwapOffset, ySwapOffset);
			self.frontView.frame = offsetRect;
		}
		completion:^(BOOL finished)
		{
            // Manually forward the view methods to the child view controllers
            [self.frontViewController viewWillDisappear:animated];
			[self _removeViewControllerFromHierarchy:self.frontViewController];
            [self.frontViewController viewDidDisappear:animated];
            
			[newFrontViewController retain]; 
			[_frontViewController release];
			_frontViewController = newFrontViewController;
			
            [newFrontViewController viewWillAppear:animated];
			[self _addFrontViewControllerToHierarchy:newFrontViewController];
            [newFrontViewController viewDidAppear:animated];
			 
			[UIView animateWithDuration:0.225f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^
			{
				CGRect offsetRect = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				self.frontView.frame = offsetRect;
			}
			completion:^(BOOL finished)
			{
				[self revealToggle:self];
				  
				if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
				{
					[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
				}
			}];
		}];
	}
	else
	{
        // Manually forward the view methods to the child view controllers
        [self.frontViewController viewWillDisappear:animated];
        [self _removeViewControllerFromHierarchy:self.frontViewController];
        [self.frontViewController viewDidDisappear:animated];
        
        [newFrontViewController retain]; 
        [_frontViewController release];
        _frontViewController = newFrontViewController;
        
        [newFrontViewController viewWillAppear:animated];
        [self _addFrontViewControllerToHierarchy:newFrontViewController];
        [newFrontViewController viewDidAppear:animated];
		
		if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
		{
			[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
		}
		
		[self revealToggle:self];
	}
}

#pragma mark - UIViewController Containment

- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController
{
	[self addChildViewController:frontViewController];
	
	// iOS 4 doesn't adjust the frame properly if in landscape via implicit loading from a nib.
	frontViewController.view.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	
	[self.frontView addSubview:frontViewController.view];
		
	if ([frontViewController respondsToSelector:@selector(didMoveToParentViewController:)])
	{
		[frontViewController didMoveToParentViewController:self];
	}
}

- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController
{
	[self addChildViewController:rearViewController];
	[self.rearView addSubview:rearViewController.view];
		
	if ([rearViewController respondsToSelector:@selector(didMoveToParentViewController:)])
	{
		[rearViewController didMoveToParentViewController:self];
	}
}

- (void)_removeViewControllerFromHierarchy:(UIViewController *)viewController
{
	[viewController.view removeFromSuperview];
	if ([viewController respondsToSelector:@selector(removeFromParentViewController)])
	{
		[viewController removeFromParentViewController];		
	}
}

#pragma mark - View Event Forwarding

/* 
 Thanks to jtoce ( https://github.com/jtoce ) for adding the event forwarding.
*/

/*
 *
 *   If you override automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers and return NO, you  
 *   are responsible for forwarding the following methods to child view controllers at the appropriate times:
 *   
 *   viewWillAppear:
 *   viewDidAppear:
 *   viewWillDisappear:
 *   viewDidDisappear:
 *   willRotateToInterfaceOrientation:duration:
 *   willAnimateRotationToInterfaceOrientation:duration:
 *   didRotateFromInterfaceOrientation:
 *
 */

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.frontViewController viewWillAppear:animated];
    [self.rearViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.frontViewController viewDidAppear:animated];
    [self.rearViewController viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.frontViewController viewWillDisappear:animated];
    [self.rearViewController viewWillDisappear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.frontViewController viewDidDisappear:animated];
    [self.rearViewController viewDidDisappear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.frontViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.rearViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.frontViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.rearViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.frontViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.rearViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
	
	/* 
	 * Create a fancy shadow aroung the frontView.
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
	
	// Init the position with only the front view visible.
	self.previousPanOffset = 0.0f;
	self.currentFrontViewPosition = FrontViewPositionTopLeft;
	
	[self _addRearViewControllerToHierarchy:self.rearViewController];
	[self _addFrontViewControllerToHierarchy:self.frontViewController];	
}

- (void)viewDidUnload
{
	[self _removeViewControllerFromHierarchy:self.frontViewController];
	[self _removeViewControllerFromHierarchy:self.rearViewController];
	
	self.frontView = nil;
    self.rearView = nil;
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
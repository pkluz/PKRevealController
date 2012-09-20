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

#import "ZUUIRevealController.h"

@interface ZUUIRevealController()

// Private Properties:
@property (strong, nonatomic) UIView *frontView;
@property (strong, nonatomic) UIView *rearView;
@property (assign, nonatomic) float previousPanOffset;

// Private Methods:
- (void)_loadDefaultConfiguration;

- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x;
- (void)_revealAnimationWithDuration:(NSTimeInterval)duration;
- (void)_concealAnimationWithDuration:(NSTimeInterval)duration resigningCompletelyFromRearViewPresentationMode:(BOOL)resigning;
- (void)_concealPartiallyAnimationWithDuration:(NSTimeInterval)duration;

- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer;

- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController;
- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController;
- (void)_removeViewControllerFromHierarchy:(UIViewController *)frontViewController;

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animated:(BOOL)animated;

@end

@implementation ZUUIRevealController

@synthesize previousPanOffset = _previousPanOffset;
@synthesize currentFrontViewPosition = _currentFrontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize frontView = _frontView;
@synthesize rearView = _rearView;
@synthesize delegate = _delegate;

@synthesize rearViewRevealWidth = _rearViewRevealWidth;
@synthesize maxRearViewRevealOverdraw = _maxRearViewRevealOverdraw;
@synthesize rearViewPresentationWidth = _rearViewPresentationWidth;
@synthesize revealViewTriggerWidth = _revealViewTriggerWidth;
@synthesize concealViewTriggerWidth = _concealViewTriggerWidth;
@synthesize quickFlickVelocity = _quickFlickVelocity;
@synthesize toggleAnimationDuration = _toggleAnimationDuration;
@synthesize frontViewShadowRadius = _frontViewShadowRadius;

#pragma mark - Initialization

- (id)initWithFrontViewController:(UIViewController *)frontViewController rearViewController:(UIViewController *)rearViewController
{
	self = [super init];
	
	if (nil != self)
	{
#if __has_feature(objc_arc)
		_frontViewController = frontViewController;
		_rearViewController = rearViewController;
#else
		[frontViewController retain];
		_frontViewController = frontViewController;
		[rearViewController retain];
		_rearViewController = rearViewController;
#endif
		[self _loadDefaultConfiguration];
	}
	
	return self;
}

- (void)_loadDefaultConfiguration
{
	self.rearViewRevealWidth = 260.0f;
	self.maxRearViewRevealOverdraw = 60.0f;
	self.rearViewPresentationWidth = 320.0f;
	self.revealViewTriggerWidth = 125.0f;
	self.concealViewTriggerWidth = 200.0f;
	self.quickFlickVelocity = 1300.0f;
	self.toggleAnimationDuration = 0.25f;
	self.frontViewShadowRadius = 2.5f;
}

#pragma mark - Reveal

/* Instantaneously toggle the rear view's visibility using the default duration.
 */
- (void)revealToggle:(id)sender
{	
	[self revealToggle:sender animationDuration:self.toggleAnimationDuration];
}

/* Instantaneously toggle the rear view's visibility using custom duration.
 */
- (void)revealToggle:(id)sender animationDuration:(NSTimeInterval)animationDuration
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
		
		[self _revealAnimationWithDuration:animationDuration];
		
		self.currentFrontViewPosition = FrontViewPositionRight;
	}
	else if (FrontViewPositionRight == self.currentFrontViewPosition)
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
		
		[self _concealAnimationWithDuration:animationDuration resigningCompletelyFromRearViewPresentationMode:NO];
		
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
	else // FrontViewPositionRightMost == self.currentFrontViewPosition
	{
		// Check if a delegate exists and if so, whether it is fine for us to hiding the rear view.
		if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
		{
			if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController])
			{
				[self showFrontViewCompletely:NO];
				return;
			}
		}
		
		[self showFrontViewCompletely:YES];
	}
}

- (void)_revealAnimationWithDuration:(NSTimeInterval)duration
{	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(self.rearViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
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

- (void)_concealAnimationWithDuration:(NSTimeInterval)duration resigningCompletelyFromRearViewPresentationMode:(BOOL)resigning
{	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		if (resigning)
		{
			// Dispatch message to delegate, telling it the 'rearView' _DID_ resign full-screen presentation mode, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didResignRearViewControllerPresentationMode:)])
			{
				[self.delegate revealController:self didResignRearViewControllerPresentationMode:self.rearViewController];
			}
		}
		
		// Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
		{
			[self.delegate revealController:self didHideRearViewController:self.rearViewController];
		}
	}];
}

- (void)_concealPartiallyAnimationWithDuration:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(self.rearViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		// Dispatch message to delegate, telling it the 'rearView' _DID_ resign its full-screen presentation mode, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:didResignRearViewControllerPresentationMode:)])
		{
			[self.delegate revealController:self didResignRearViewControllerPresentationMode:self.rearViewController];
		}
	}];
}

- (void)_revealCompletelyAnimationWithDuration:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(self.rearViewPresentationWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		// Dispatch message to delegate, telling it the 'rearView' _DID_ enter its full-screen presentation mode, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:didEnterRearViewControllerPresentationMode:)])
		{
			[self.delegate revealController:self didEnterRearViewControllerPresentationMode:self.rearViewController];
		}
	}];
}

- (void)hideFrontView
{
	if (self.currentFrontViewPosition == FrontViewPositionRightMost)
	{
		return;
	}
	
	// Dispatch message to delegate, telling it the 'rearView' _WILL_ enter its full-screen presentation mode, if appropriate:
	if ([self.delegate respondsToSelector:@selector(revealController:willEnterRearViewControllerPresentationMode:)])
	{
		[self.delegate revealController:self willEnterRearViewControllerPresentationMode:self.rearViewController];
	}
	
	[self _revealCompletelyAnimationWithDuration:self.toggleAnimationDuration*0.5f];
	self.currentFrontViewPosition = FrontViewPositionRightMost;
}

- (void)showFrontViewCompletely:(BOOL)completely
{
	if (self.currentFrontViewPosition != FrontViewPositionRightMost)
	{
		return;
	}
	
	// Dispatch message to delegate, telling it the 'rearView' _WILL_ resign its full-screen presentation mode, if appropriate:
	if ([self.delegate respondsToSelector:@selector(revealController:willResignRearViewControllerPresentationMode:)])
	{
		[self.delegate revealController:self willResignRearViewControllerPresentationMode:self.rearViewController];
	}
	
	if (completely)
	{
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ hide, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
		{
			[self.delegate revealController:self willHideRearViewController:self.rearViewController];
		}
		
		[self _concealAnimationWithDuration:self.toggleAnimationDuration resigningCompletelyFromRearViewPresentationMode:YES];
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
	else
	{
		[self _concealPartiallyAnimationWithDuration:self.toggleAnimationDuration*0.5f];
		self.currentFrontViewPosition = FrontViewPositionRight;
	}
}

#pragma mark - Gesture Based Reveal

/* Slowly reveal or hide the rear view based on the translation of the finger.
 */
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer
{	
	// Ask the delegate (if appropriate) if we are allowed to proceed with our interaction:
	if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)])
	{
		// We're going to be revealing.
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
		// We're going to be concealing.
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
	
	switch ([recognizer state])
	{
		case UIGestureRecognizerStateBegan:
		{
			[self _handleRevealGestureStateBeganWithRecognizer:recognizer];
		}
			break;
			
		case UIGestureRecognizerStateChanged:
		{
			[self _handleRevealGestureStateChangedWithRecognizer:recognizer];
		}
			break;
			
		case UIGestureRecognizerStateEnded:
		{
			[self _handleRevealGestureStateEndedWithRecognizer:recognizer];
		}
			break;
			
		default:
			break;
	}
}

- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
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

- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
	if (FrontViewPositionLeft == self.currentFrontViewPosition)
	{
		if ([recognizer translationInView:self.view].x < 0.0f)
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else
		{
			float offset = [self _calculateOffsetForTranslationInView:[recognizer translationInView:self.view].x];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
	else
	{
		if ([recognizer translationInView:self.view].x > 0.0f)
		{
			float offset = [self _calculateOffsetForTranslationInView:([recognizer translationInView:self.view].x+self.rearViewRevealWidth)];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else if ([recognizer translationInView:self.view].x > -self.rearViewRevealWidth)
		{
			self.frontView.frame = CGRectMake([recognizer translationInView:self.view].x+self.rearViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		else
		{
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
}

- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
	// Case a): Quick finger flick fast enough to cause instant change:
	if (fabs([recognizer velocityInView:self.view].x) > self.quickFlickVelocity)
	{
		if ([recognizer velocityInView:self.view].x > 0.0f)
		{				
			[self _revealAnimationWithDuration:self.toggleAnimationDuration];
		}
		else
		{
			[self _concealAnimationWithDuration:self.toggleAnimationDuration resigningCompletelyFromRearViewPresentationMode:NO];
		}
	}
	// Case b) Slow pan/drag ended:
	else
	{
		float dynamicTriggerLevel = (FrontViewPositionLeft == self.currentFrontViewPosition) ? self.revealViewTriggerWidth : self.concealViewTriggerWidth;
		
		if (self.frontView.frame.origin.x >= dynamicTriggerLevel && self.frontView.frame.origin.x != self.rearViewRevealWidth)
		{
			[self _revealAnimationWithDuration:self.toggleAnimationDuration];
		}
		else
		{
			[self _concealAnimationWithDuration:self.toggleAnimationDuration resigningCompletelyFromRearViewPresentationMode:NO];
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
}

#pragma mark - Helper

/* Note: If someone wants to bother to implement a better (smoother) function. Go for it and share!
 */
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x
{
	CGFloat result;
	
	if (x <= self.rearViewRevealWidth)
	{
		// Translate linearly.
		result = x;
	}
	else if (x <= self.rearViewRevealWidth+(M_PI*self.maxRearViewRevealOverdraw/2.0f))
	{
		// and eventually slow translation slowly.
		result = self.maxRearViewRevealOverdraw*sin((x-self.rearViewRevealWidth)/self.maxRearViewRevealOverdraw)+self.rearViewRevealWidth;
	}
	else
	{
		// ...until we hit the limit.
		result = self.rearViewRevealWidth+self.maxRearViewRevealOverdraw;
	}
	
	return result;
}

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(revealController:willSwapToFrontViewController:)])
	{
		[self.delegate revealController:self willSwapToFrontViewController:newFrontViewController];
	}
	
	CGFloat xSwapOffset = 0.0f;
	
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		xSwapOffset = 60.0f;
	}
	
	if (animated)
	{
		[UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^
		{
			CGRect offsetRect = CGRectOffset(self.frontView.frame, xSwapOffset, 0.0f);
			self.frontView.frame = offsetRect;
		}
		completion:^(BOOL finished)
		{
			// Manually forward the view methods to the child view controllers
			[self.frontViewController viewWillDisappear:animated];
			[self _removeViewControllerFromHierarchy:_frontViewController];
			[self.frontViewController viewDidDisappear:animated];
			
#if __has_feature(objc_arc)
			_frontViewController = newFrontViewController;
#else
			[newFrontViewController retain]; 
			[_frontViewController release];
			_frontViewController = newFrontViewController;
#endif
			 
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
#if __has_feature(objc_arc)
		_frontViewController = newFrontViewController;
#else
		[newFrontViewController retain]; 
		[_frontViewController release];
		_frontViewController = newFrontViewController;
#endif
		
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

#pragma mark - Accessors

- (void)setFrontViewController:(UIViewController *)frontViewController
{
	[self setFrontViewController:frontViewController animated:NO];
}

- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated
{
	if (nil != frontViewController && _frontViewController == frontViewController)
	{
		[self revealToggle:self];
	}
	else if (nil != frontViewController)
	{
		[self _swapCurrentFrontViewControllerWith:frontViewController animated:animated];
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
 Thanks to jtoce ( https://github.com/jtoce ) for adding iOS 4 Support!
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
	
#if __has_feature(objc_arc)
	self.frontView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.rearView = [[UIView alloc] initWithFrame:self.view.bounds];
#else
	self.frontView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.rearView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
#endif
	
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
	self.frontView.layer.shadowRadius = self.frontViewShadowRadius;
	self.frontView.layer.shadowPath = shadowPath.CGPath;
	
	// Init the position with only the front view visible.
	self.previousPanOffset = 0.0f;
	self.currentFrontViewPosition = FrontViewPositionLeft;
	
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_5_1
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

#pragma mark - Memory Management

#if __has_feature(objc_arc)
#else
- (void)dealloc
{
	[_frontViewController release], _frontViewController = nil;
	[_rearViewController release], _rearViewController = nil;
	[_frontView release], _frontView = nil;
	[_rearView release], _rearView = nil;
	[super dealloc];
}
#endif

@end
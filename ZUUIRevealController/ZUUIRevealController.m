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

typedef enum ZUUIRevealControllerFrontViewAnim: NSUInteger {
	ZUUIRevealControllerFrontViewAnimNone,
	ZUUIRevealControllerFrontViewAnimShowFullMenu,
	ZUUIRevealControllerFrontViewAnimFade
} ZUUIRevealControllerFrontViewAnim;

@interface ZUUIRevealController()

// Private Properties:
@property (strong, nonatomic) UIView *frontView;
@property (strong, nonatomic) UIView *rearView;
@property (strong, nonatomic) UIView *learView;
@property (assign, nonatomic) float previousPanOffset;

// Private Methods:
- (void)_loadDefaultConfiguration;

- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x forRearView:(BOOL)forRear;
- (void)_revealAnimationWithDuration:(NSTimeInterval)duration toRear:(BOOL)destIsRear; /* If dest is not rear, it is lear */
- (void)_concealAnimationWithDuration:(NSTimeInterval)duration fromRear:(BOOL)fromRear resigningCompletelyFromXearViewPresentationMode:(BOOL)resigning;
- (void)_concealPartiallyAnimationWithDuration:(NSTimeInterval)duration fromRear:(BOOL)fromRear;

- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer;

- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController;
- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController;
- (void)_removeViewControllerFromHierarchy:(UIViewController *)frontViewController;

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animation:(ZUUIRevealControllerFrontViewAnim)animated;

- (void)_showLear;
- (void)_showRear;

@end

@implementation ZUUIRevealController

@synthesize previousPanOffset = _previousPanOffset;
@synthesize currentFrontViewPosition = _currentFrontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize learViewController = _learViewController;
@synthesize frontView = _frontView;
@synthesize rearView = _rearView;
@synthesize learView = _learView;
@synthesize delegate = _delegate;
@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

@synthesize rearViewRevealWidth = _rearViewRevealWidth;
@synthesize maxRearViewRevealOverdraw = _maxRearViewRevealOverdraw;
@synthesize rearViewPresentationWidth = _rearViewPresentationWidth;
@synthesize learViewRevealWidth = _learViewRevealWidth;
@synthesize maxLearViewRevealOverdraw = _maxLearViewRevealOverdraw;
@synthesize learViewPresentationWidth = _learViewPresentationWidth;
@synthesize revealRearViewTriggerWidth = _revealRearViewTriggerWidth;
@synthesize revealLearViewTriggerWidth = _revealLearViewTriggerWidth;
@synthesize concealRearViewTriggerWidth = _concealRearViewTriggerWidth;
@synthesize concealLearViewTriggerWidth = _concealLearViewTriggerWidth;
@synthesize quickFlickVelocity = _quickFlickVelocity;
@synthesize toggleAnimationDuration = _toggleAnimationDuration;
@synthesize frontViewShadowRadius = _frontViewShadowRadius;

#pragma mark - Initialization

- (id)initWithFrontViewController:(UIViewController *)frontViewController rearViewController:(UIViewController *)rearViewController
{
	return [self initWithFrontViewController:frontViewController rearViewController:rearViewController learViewController:nil];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController rearViewController:(UIViewController *)rearViewController learViewController:(UIViewController *)learViewController
{
	self = [super init];
	
	if (nil != self)
	{
#if __has_feature(objc_arc)
		_frontViewController = frontViewController;
		_rearViewController = rearViewController;
		_learViewController = learViewController;
#else
		[frontViewController retain];
		_frontViewController = frontViewController;
		[rearViewController retain];
		_rearViewController = rearViewController;
		[learViewController retain];
		_learViewController = learViewController;
#endif
		[self _loadDefaultConfiguration];
	}
	
	return self;
}

- (void)_loadDefaultConfiguration
{
	self.rearViewRevealWidth = 260.0f;
	self.learViewRevealWidth = 260.0f;
	self.maxRearViewRevealOverdraw = 60.0f;
	self.maxLearViewRevealOverdraw = 60.0f;
	self.rearViewPresentationWidth = 320.0f;
	self.learViewPresentationWidth = 320.0f;
	
	self.revealRearViewTriggerWidth = 125.0f;
	self.revealLearViewTriggerWidth = 125.0f;
	self.concealRearViewTriggerWidth = 200.0f;
	self.concealLearViewTriggerWidth = 200.0f;
	self.quickFlickVelocity = 1300.0f;
	self.toggleAnimationDuration = 0.25f;
	self.frontViewShadowRadius = 2.5f;
	self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Reveal

/* Instantaneously toggle the rear view's visibility using the default duration.
 */
- (void)revealRearToggle:(id)sender
{
	[self revealRearToggle:sender animationDuration:self.toggleAnimationDuration];
}

/* Instantaneously toggle the lear view's visibility using the default duration.
 */
- (void)revealLearToggle:(id)sender
{
	[self revealLearToggle:sender animationDuration:self.toggleAnimationDuration];
}

/* Instantaneously toggle the rear view's visibility using custom duration.
 */
- (void)revealRearToggle:(id)sender animationDuration:(NSTimeInterval)animationDuration
{
	switch (self.currentFrontViewPosition) {
		case FrontViewPositionLeft: /* No Break */
		case FrontViewPositionLeftMost: /* No Break */
		case FrontViewPositionCenter:
			// Check if a delegate exists and if so, whether it is fine for us to revealing the rear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
				if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController])
					return;
			
			// Dispatch message to delegate, telling it the 'rearView' _WILL_ reveal, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
				[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
			
			[self _revealAnimationWithDuration:animationDuration toRear:YES];
			
			self.currentFrontViewPosition = FrontViewPositionRight;
			break;
		case FrontViewPositionRight:
			// Check if a delegate exists and if so, whether it is fine for us to hiding the rear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
				if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController])
					return;
			
			// Dispatch message to delegate, telling it the 'rearView' _WILL_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
				[self.delegate revealController:self willHideRearViewController:self.rearViewController];
			
			[self _concealAnimationWithDuration:animationDuration fromRear:YES resigningCompletelyFromXearViewPresentationMode:NO];
			
			self.currentFrontViewPosition = FrontViewPositionCenter;
			break;
		case FrontViewPositionRightMost:
			// Check if a delegate exists and if so, whether it is fine for us to hiding the rear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)]) {
				if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController]) {
					[self showFrontViewCompletely:NO];
					return;
				}
			}
			
			[self showFrontViewCompletely:YES];
		default:
			NSLog(@"*** Warning: Unknown current front view position: %lu", (unsigned long)self.currentFrontViewPosition);
	}
}

- (void)revealLearToggle:(id)sender animationDuration:(NSTimeInterval)animationDuration
{
	switch (self.currentFrontViewPosition) {
		case FrontViewPositionRight: /* No Break */
		case FrontViewPositionRightMost: /* No Break */
		case FrontViewPositionCenter:
			// Check if a delegate exists and if so, whether it is fine for us to revealing the lear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealLearViewController:)])
				if (![self.delegate revealController:self shouldRevealLearViewController:self.learViewController])
					return;
			
			// Dispatch message to delegate, telling it the 'learView' _WILL_ reveal, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willRevealLearViewController:)])
				[self.delegate revealController:self willRevealLearViewController:self.learViewController];
			
			[self _revealAnimationWithDuration:animationDuration toRear:NO];
			
			self.currentFrontViewPosition = FrontViewPositionLeft;
			break;
		case FrontViewPositionLeft:
			// Check if a delegate exists and if so, whether it is fine for us to hiding the lear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideLearViewController:)])
				if (![self.delegate revealController:self shouldHideLearViewController:self.learViewController])
					return;
			
			// Dispatch message to delegate, telling it the 'learView' _WILL_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willHideLearViewController:)])
				[self.delegate revealController:self willHideLearViewController:self.learViewController];
			
			[self _concealAnimationWithDuration:animationDuration fromRear:NO resigningCompletelyFromXearViewPresentationMode:NO];
			
			self.currentFrontViewPosition = FrontViewPositionCenter;
			break;
		case FrontViewPositionLeftMost:
			// Check if a delegate exists and if so, whether it is fine for us to hiding the lear view.
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideLearViewController:)]) {
				if (![self.delegate revealController:self shouldHideLearViewController:self.learViewController]) {
					[self showFrontViewCompletely:NO];
					return;
				}
			}
			
			[self showFrontViewCompletely:YES];
		default:
			NSLog(@"*** Warning: Unknown current front view position: %lu", (unsigned long)self.currentFrontViewPosition);
	}
}

- (void)_revealAnimationWithDuration:(NSTimeInterval)duration toRear:(BOOL)destIsRear
{
	if (destIsRear) [self _showRear];
	else            [self _showLear];
	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(destIsRear? self.rearViewRevealWidth: -self.learViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		if (destIsRear) {
			// Dispatch message to delegate, telling it the 'rearView' _DID_ reveal, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
				[self.delegate revealController:self didRevealRearViewController:self.rearViewController];
		} else {
			// Dispatch message to delegate, telling it the 'learView' _DID_ reveal, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didRevealLearViewController:)])
				[self.delegate revealController:self didRevealLearViewController:self.learViewController];
		}
	}];
}

- (void)_concealAnimationWithDuration:(NSTimeInterval)duration fromRear:(BOOL)fromRear resigningCompletelyFromXearViewPresentationMode:(BOOL)resigning
{	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		if (resigning) {
			if (fromRear) {
				// Dispatch message to delegate, telling it the 'rearView' _DID_ resign full-screen presentation mode, if appropriate:
				if ([self.delegate respondsToSelector:@selector(revealController:didResignRearViewControllerPresentationMode:)])
					[self.delegate revealController:self didResignRearViewControllerPresentationMode:self.rearViewController];
			} else {
				// Dispatch message to delegate, telling it the 'learView' _DID_ resign full-screen presentation mode, if appropriate:
				if ([self.delegate respondsToSelector:@selector(revealController:didResignLearViewControllerPresentationMode:)])
					[self.delegate revealController:self didResignLearViewControllerPresentationMode:self.learViewController];
			}
		}
		
		if (fromRear) {
			// Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
				[self.delegate revealController:self didHideRearViewController:self.rearViewController];
		} else {
			// Dispatch message to delegate, telling it the 'learView' _DID_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didHideLearViewController:)])
				[self.delegate revealController:self didHideLearViewController:self.learViewController];
		}
	}];
}

- (void)_concealPartiallyAnimationWithDuration:(NSTimeInterval)duration fromRear:(BOOL)fromRear
{
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(fromRear? self.rearViewRevealWidth: -self.learViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		if (fromRear) {
			// Dispatch message to delegate, telling it the 'rearView' _DID_ resign its full-screen presentation mode, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didResignRearViewControllerPresentationMode:)])
				[self.delegate revealController:self didResignRearViewControllerPresentationMode:self.rearViewController];
		} else {
			// Dispatch message to delegate, telling it the 'learView' _DID_ resign its full-screen presentation mode, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didResignLearViewControllerPresentationMode:)])
				[self.delegate revealController:self didResignLearViewControllerPresentationMode:self.learViewController];
		}
	}];
}

- (void)_revealCompletelyAnimationWithDuration:(NSTimeInterval)duration toRear:(BOOL)toRear
{
	if (toRear) [self _showRear];
	else        [self _showLear];
	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
	{
		self.frontView.frame = CGRectMake(toRear? self.rearViewPresentationWidth: -self.learViewPresentationWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
	}
	completion:^(BOOL finished)
	{
		if (toRear) {
			// Dispatch message to delegate, telling it the 'rearView' _DID_ enter its full-screen presentation mode, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didEnterRearViewControllerPresentationMode:)])
				[self.delegate revealController:self didEnterRearViewControllerPresentationMode:self.rearViewController];
		} else {
			// Dispatch message to delegate, telling it the 'learView' _DID_ enter its full-screen presentation mode, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:didEnterLearViewControllerPresentationMode:)])
				[self.delegate revealController:self didEnterLearViewControllerPresentationMode:self.learViewController];
		}
	}];
}

- (void)hideFrontViewToRear
{
	if (self.currentFrontViewPosition == FrontViewPositionRightMost)
		return;
	
	[self _showRear];
	
	// Dispatch message to delegate, telling it the 'rearView' _WILL_ enter its full-screen presentation mode, if appropriate:
	if ([self.delegate respondsToSelector:@selector(revealController:willEnterRearViewControllerPresentationMode:)])
		[self.delegate revealController:self willEnterRearViewControllerPresentationMode:self.rearViewController];
	
	[self _revealCompletelyAnimationWithDuration:self.toggleAnimationDuration*0.5f toRear:YES];
	self.currentFrontViewPosition = FrontViewPositionRightMost;
}

- (void)hideFrontViewToLear
{
	if (self.currentFrontViewPosition == FrontViewPositionLeftMost)
		return;
	
	[self _showLear];
	
	// Dispatch message to delegate, telling it the 'learView' _WILL_ enter its full-screen presentation mode, if appropriate:
	if ([self.delegate respondsToSelector:@selector(revealController:willEnterLearViewControllerPresentationMode:)])
		[self.delegate revealController:self willEnterLearViewControllerPresentationMode:self.learViewController];
	
	[self _revealCompletelyAnimationWithDuration:self.toggleAnimationDuration*0.5f toRear:NO];
	self.currentFrontViewPosition = FrontViewPositionLeftMost;
}

- (void)showFrontViewCompletely:(BOOL)completely
{
	if (self.currentFrontViewPosition != FrontViewPositionRightMost && self.currentFrontViewPosition != FrontViewPositionLeftMost)
		return;
	
	BOOL fromRear = (self.currentFrontViewPosition == FrontViewPositionRightMost);
	
	if (fromRear) {
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ resign its full-screen presentation mode, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willResignRearViewControllerPresentationMode:)])
			[self.delegate revealController:self willResignRearViewControllerPresentationMode:self.rearViewController];
	} else {
		// Dispatch message to delegate, telling it the 'learView' _WILL_ resign its full-screen presentation mode, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willResignLearViewControllerPresentationMode:)])
			[self.delegate revealController:self willResignLearViewControllerPresentationMode:self.learViewController];
	}
	
	if (completely) {
		if (fromRear) {
			// Dispatch message to delegate, telling it the 'rearView' _WILL_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
				[self.delegate revealController:self willHideRearViewController:self.rearViewController];
		} else {
			// Dispatch message to delegate, telling it the 'learView' _WILL_ hide, if appropriate:
			if ([self.delegate respondsToSelector:@selector(revealController:willHideLearViewController:)])
				[self.delegate revealController:self willHideLearViewController:self.learViewController];
		}
		
		[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:fromRear resigningCompletelyFromXearViewPresentationMode:YES];
		self.currentFrontViewPosition = FrontViewPositionCenter;
	} else {
		[self _concealPartiallyAnimationWithDuration:self.toggleAnimationDuration*0.5f fromRear:fromRear];
		self.currentFrontViewPosition = fromRear? FrontViewPositionRight: FrontViewPositionLeft;
	}
}

#pragma mark - Gesture Based Reveal

/* Slowly reveal or hide the rear view based on the translation of the finger.
 */
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer
{	
	// Ask the delegate (if appropriate) if we are allowed to proceed with our interaction:
	if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)]) {
		if (FrontViewPositionCenter == self.currentFrontViewPosition) {
			// We're going to be revealing.
			/* The reveal gesture used to check here if the delegate allows revealing the rear view
			 * controller. However, because there is now a lear view to deal with too, we cannot do this
			 * here anymore and have to analyse the gesture before calling the delegate */
		} else {
			// We're going to be concealing.
			if (self.currentFrontViewPosition == FrontViewPositionRight || self.currentFrontViewPosition == FrontViewPositionRightMost) {
				/* Concealing the rear view */
				if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
					if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController])
						return;
			} else {
				/* Concealing the lear view */
				if ([self.delegate respondsToSelector:@selector(revealController:shouldHideLearViewController:)])
					if (![self.delegate revealController:self shouldHideLearViewController:self.learViewController])
						return;
			}
		}
	}
	
	switch ([recognizer state]) {
		case UIGestureRecognizerStateBegan:
			[self _handleRevealGestureStateBeganWithRecognizer:recognizer];
			break;
		case UIGestureRecognizerStateChanged:
			[self _handleRevealGestureStateChangedWithRecognizer:recognizer];
			break;
		case UIGestureRecognizerStateEnded:
			[self _handleRevealGestureStateEndedWithRecognizer:recognizer];
			break;
		default:
			/* Nop */;
	}
}

- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
	// Check if a delegate exists
	if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)]) {
		// Determine whether we're going to be revealing or hiding.
		if (FrontViewPositionCenter == self.currentFrontViewPosition) {
			/* The reveal gesture used to inform here the delegate that we were revealing the rear view
			 * controller. However, because there is now a lear view to deal with too, we cannot do this
			 * here anymore and have to analyse the gesture before calling the delegate */
		} else {
			if (self.currentFrontViewPosition == FrontViewPositionRight || self.currentFrontViewPosition == FrontViewPositionRightMost) {
				/* Concealing the rear view */
				if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
					[self.delegate revealController:self willHideRearViewController:self.rearViewController];
			} else {
				/* Concealing the lear view */
				if ([self.delegate respondsToSelector:@selector(revealController:willHideLearViewController:)])
					[self.delegate revealController:self willHideLearViewController:self.learViewController];
			}
		}
	}
}

- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
	switch (self.currentFrontViewPosition) {
		case FrontViewPositionCenter: {
			float t = [recognizer translationInView:self.view].x;
			float offset = [self _calculateOffsetForTranslationInView:t forRearView:t > 0.0f];
			
			if ((offset > 0. && self.frontView.frame.origin.x <= 0.) ||
				 (offset < 0. && self.frontView.frame.origin.x >= 0.)) {
				if (offset > 0.) {
					/* Trying to show the rear view */
					[self _showRear];
					if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
						if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController])
							return;
					
					if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
						[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
				} else {
					/* Trying to show the lear view */
					[self _showLear];
					if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealLearViewController:)])
						if (![self.delegate revealController:self shouldRevealLearViewController:self.learViewController])
							return;
					
					if ([self.delegate respondsToSelector:@selector(revealController:willRevealLearViewController:)])
						[self.delegate revealController:self willRevealLearViewController:self.learViewController];
				}
			}
			
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			break;
		}
		case FrontViewPositionRight:
			if ([recognizer translationInView:self.view].x > 0.0f) {
				/* We're moving to the right */
				float offset = [self _calculateOffsetForTranslationInView:([recognizer translationInView:self.view].x+self.rearViewRevealWidth) forRearView:YES];
				self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			} else if ([recognizer translationInView:self.view].x > -self.rearViewRevealWidth) {
				/* We're moved to the left, but less than the rear view reveal width */
				self.frontView.frame = CGRectMake([recognizer translationInView:self.view].x+self.rearViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			} else {
				self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			}
			break;
		case FrontViewPositionLeft:
			if ([recognizer translationInView:self.view].x < 0.0f) {
				/* We're moving to the left */
				float offset = [self _calculateOffsetForTranslationInView:([recognizer translationInView:self.view].x-self.learViewRevealWidth) forRearView:NO];
				self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			} else if ([recognizer translationInView:self.view].x < self.learViewRevealWidth) {
				/* We're moved to the right, but less than the lear view reveal width */
				self.frontView.frame = CGRectMake([recognizer translationInView:self.view].x-self.learViewRevealWidth, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			} else {
				self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			}
			break;
		case FrontViewPositionLeftMost: /* No Break */
		case FrontViewPositionRightMost:
			NSAssert(NO, @"Impossible front view position %lu in %@.", (unsigned long)self.currentFrontViewPosition, NSStringFromSelector(_cmd));
		default:
			NSLog(@"*** Warning: Unknown current front view position: %lu", (unsigned long)self.currentFrontViewPosition);
	}
}

- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
	// Case a): Quick finger flick fast enough to cause instant change:
	if (fabs([recognizer velocityInView:self.view].x) > self.quickFlickVelocity)
	{
		switch (self.currentFrontViewPosition) {
			case FrontViewPositionCenter:
				[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:[recognizer velocityInView:self.view].x > 0.0f];
				break;
			case FrontViewPositionRight:
				if ([recognizer velocityInView:self.view].x > 0.0f) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:YES];
				} else {
					[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:YES resigningCompletelyFromXearViewPresentationMode:NO];
				}
				break;
			case FrontViewPositionLeft:
				if ([recognizer velocityInView:self.view].x < 0.0f) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:NO];
				} else {
					[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:NO resigningCompletelyFromXearViewPresentationMode:NO];
				}
				break;
			case FrontViewPositionLeftMost: /* No Break */
			case FrontViewPositionRightMost:
				NSAssert(NO, @"Impossible front view position %lu in %@.", (unsigned long)self.currentFrontViewPosition, NSStringFromSelector(_cmd));
			default:
				NSLog(@"*** Warning: Unknown current front view position: %lu", (unsigned long)self.currentFrontViewPosition);
		}
	}
	// Case b) Slow pan/drag ended:
	else
	{
		float dynamicTriggerLevel = 0.;
		switch (self.currentFrontViewPosition) {
			case FrontViewPositionCenter:
				if (self.frontView.frame.origin.x >= self.revealRearViewTriggerWidth) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:YES];
				} else if (self.frontView.frame.origin.x <= -self.revealLearViewTriggerWidth) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:NO];
				} else {
					[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:(self.frontView.frame.origin.x >= 0.) resigningCompletelyFromXearViewPresentationMode:NO];
				}
				break;
			case FrontViewPositionRight:
				dynamicTriggerLevel = self.concealRearViewTriggerWidth;
				if (self.frontView.frame.origin.x >= dynamicTriggerLevel) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:YES];
				} else {
					[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:YES resigningCompletelyFromXearViewPresentationMode:NO];
				}
				break;
			case FrontViewPositionLeft:
				dynamicTriggerLevel = -self.concealLearViewTriggerWidth;
				if (self.frontView.frame.origin.x <= dynamicTriggerLevel) {
					[self _revealAnimationWithDuration:self.toggleAnimationDuration toRear:NO];
				} else {
					[self _concealAnimationWithDuration:self.toggleAnimationDuration fromRear:NO resigningCompletelyFromXearViewPresentationMode:NO];
				}
				break;
			case FrontViewPositionLeftMost: /* No Break */
			case FrontViewPositionRightMost:
				NSAssert(NO, @"Impossible front view position %lu in %@.", (unsigned long)self.currentFrontViewPosition, NSStringFromSelector(_cmd));
			default:
				NSLog(@"*** Warning: Unknown current front view position: %lu", (unsigned long)self.currentFrontViewPosition);
		}
	}
	
	// Now adjust the current state enum.
	if (self.frontView.frame.origin.x == 0.0f) {
		self.currentFrontViewPosition = FrontViewPositionCenter;
	} else if (self.frontView.frame.origin.x > 0.) {
		self.currentFrontViewPosition = FrontViewPositionRight;
	} else {
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
}

#pragma mark - Helper

/* Note: If someone wants to bother to implement a better (smoother) function. Go for it and share!
 */
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x forRearView:(BOOL)forRear
{
	CGFloat result;
	
	if (forRear) {
		if (x <= self.rearViewRevealWidth) {
			// Translate linearly.
			result = x;
		} else if (x <= self.rearViewRevealWidth+(M_PI*self.maxRearViewRevealOverdraw/2.0f)) {
			// and eventually slow translation slowly.
			result = self.maxRearViewRevealOverdraw*sin((x-self.rearViewRevealWidth)/self.maxRearViewRevealOverdraw)+self.rearViewRevealWidth;
		} else {
			// ...until we hit the limit.
			result = self.rearViewRevealWidth+self.maxRearViewRevealOverdraw;
		}
	} else {
		/* FLFL: Note: Not actually fully tested, but seems right */
		if (x >= -self.learViewRevealWidth) {
			// Translate linearly.
			result = x;
		} else if (x >= -self.rearViewRevealWidth-(M_PI*self.maxLearViewRevealOverdraw/2.0f)) {
			// and eventually slow translation slowly.
			result = +self.maxLearViewRevealOverdraw*sin((x+self.learViewRevealWidth)/self.maxLearViewRevealOverdraw)-self.learViewRevealWidth;
		} else {
			// ...until we hit the limit.
			result = -self.learViewRevealWidth-self.maxRearViewRevealOverdraw;
		}
	}

	return result;
}

- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animation:(ZUUIRevealControllerFrontViewAnim)anim
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
	
	if (anim == ZUUIRevealControllerFrontViewAnimShowFullMenu)
	{
		[UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^
		{
			CGRect offsetRect = CGRectOffset(self.frontView.frame, xSwapOffset, 0.0f);
			self.frontView.frame = offsetRect;
		}
		completion:^(BOOL finished)
		{
			// Manually forward the view methods to the child view controllers
			[self.frontViewController viewWillDisappear:YES];
			[self _removeViewControllerFromHierarchy:_frontViewController];
			[self.frontViewController viewDidDisappear:YES];
			
#if __has_feature(objc_arc)
			_frontViewController = newFrontViewController;
#else
			[newFrontViewController retain]; 
			[_frontViewController release];
			_frontViewController = newFrontViewController;
#endif
			 
			[newFrontViewController viewWillAppear:YES];
			[self _addFrontViewControllerToHierarchy:newFrontViewController];
			[newFrontViewController viewDidAppear:YES];
			 
			[UIView animateWithDuration:0.225f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^
			{
				CGRect offsetRect = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
				self.frontView.frame = offsetRect;
			}
			completion:^(BOOL finished)
			{
				[self revealRearToggle:self];
				  
				if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
				{
					[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
				}
			}];
		}];
	}
	else if (anim == ZUUIRevealControllerFrontViewAnimFade)
	{
		if (self.currentFrontViewPosition != FrontViewPositionCenter) [self revealRearToggle:self];
		
		// Manually forward the view methods to the child view controllers
		[newFrontViewController viewWillAppear:YES];
		[self.frontViewController viewWillDisappear:YES];
		newFrontViewController.view.alpha = 0.;
		[self _addFrontViewControllerToHierarchy:newFrontViewController];
		[UIView animateWithDuration:0.75f delay:0.0f options:UIViewAnimationCurveLinear animations:^
		{
			newFrontViewController.view.alpha = 1.;
			self.frontViewController.view.alpha = 0.;
		}
		completion:^(BOOL finished)
		{
			[self _removeViewControllerFromHierarchy:_frontViewController];
			[self.frontViewController viewDidDisappear:YES];
			
#if __has_feature(objc_arc)
			_frontViewController = newFrontViewController;
#else
			[newFrontViewController retain];
			[_frontViewController release];
			_frontViewController = newFrontViewController;
#endif
			
			[newFrontViewController viewDidAppear:YES];
			
			if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
			{
				[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
			}
		}];
	}
	else
	{
		// Manually forward the view methods to the child view controllers
		[self.frontViewController viewWillDisappear:NO];
		[self _removeViewControllerFromHierarchy:self.frontViewController];
		[self.frontViewController viewDidDisappear:NO];
#if __has_feature(objc_arc)
		_frontViewController = newFrontViewController;
#else
		[newFrontViewController retain]; 
		[_frontViewController release];
		_frontViewController = newFrontViewController;
#endif
		
		[newFrontViewController viewWillAppear:NO];
		[self _addFrontViewControllerToHierarchy:newFrontViewController];
		[newFrontViewController viewDidAppear:NO];
		
		if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
		{
			[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
		}
		
		[self revealRearToggle:self];
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
		[self revealRearToggle:self];
	}
	else if (nil != frontViewController)
	{
		[self _swapCurrentFrontViewControllerWith:frontViewController animation:animated? ZUUIRevealControllerFrontViewAnimShowFullMenu: ZUUIRevealControllerFrontViewAnimNone];
	}
}

- (void)setFrontViewControllerWithFade:(UIViewController *)frontViewController
{
	if (nil != frontViewController && _frontViewController == frontViewController)
	{
		if (self.currentFrontViewPosition != FrontViewPositionCenter) [self revealRearToggle:self];
	}
	else if (nil != frontViewController)
	{
		[self _swapCurrentFrontViewControllerWith:frontViewController animation:ZUUIRevealControllerFrontViewAnimFade];
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
		[frontViewController didMoveToParentViewController:self];
}

- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController
{
    // Ensures an extra StatusBar height isn't being added to the rear view
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    rearViewController.view.frame = CGRectMake(0.0, 0.0, appFrame.size.width, appFrame.size.height + statusBarFrame.size.height);

	[self addChildViewController:rearViewController];
	[self.rearView addSubview:rearViewController.view];
	
	if ([rearViewController respondsToSelector:@selector(didMoveToParentViewController:)])
		[rearViewController didMoveToParentViewController:self];
}

- (void)_addLearViewControllerToHierarchy:(UIViewController *)learViewController
{
	// Ensures an extra StatusBar height isn't being added to the lear view
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	learViewController.view.frame = CGRectMake(0.0, 0.0, appFrame.size.width, appFrame.size.height + statusBarFrame.size.height);
	
	[self addChildViewController:learViewController];
	[self.learView addSubview:learViewController.view];
	
	if ([learViewController respondsToSelector:@selector(didMoveToParentViewController:)])
		[learViewController didMoveToParentViewController:self];
}

- (void)_removeViewControllerFromHierarchy:(UIViewController *)viewController
{
	[viewController.view removeFromSuperview];
	
	if ([viewController respondsToSelector:@selector(removeFromParentViewController)])
		[viewController removeFromParentViewController];
}

- (void)_showLear
{
	NSArray *subviews = self.view.subviews;
	NSUInteger lidx = [subviews indexOfObjectIdenticalTo:self.learView];
	NSUInteger ridx = [subviews indexOfObjectIdenticalTo:self.rearView];
	if (lidx > ridx) return;
	[self.view exchangeSubviewAtIndex:lidx withSubviewAtIndex:ridx];
}

- (void)_showRear
{
	NSArray *subviews = self.view.subviews;
	NSUInteger lidx = [subviews indexOfObjectIdenticalTo:self.learView];
	NSUInteger ridx = [subviews indexOfObjectIdenticalTo:self.rearView];
	if (lidx < ridx) return;
	[self.view exchangeSubviewAtIndex:lidx withSubviewAtIndex:ridx];
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
	[self.learViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.frontViewController viewDidAppear:animated];
	[self.rearViewController viewDidAppear:animated];
	[self.learViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.frontViewController viewWillDisappear:animated];
	[self.rearViewController viewWillDisappear:animated];
	[self.learViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.frontViewController viewDidDisappear:animated];
	[self.rearViewController viewDidDisappear:animated];
	[self.learViewController viewDidDisappear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.frontViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.rearViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.learViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.frontViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.rearViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.learViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.frontViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.rearViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.learViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
#if __has_feature(objc_arc)
	self.frontView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.rearView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.learView = [[UIView alloc] initWithFrame:self.view.bounds];
#else
	self.frontView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.rearView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.learView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
#endif
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizedOnFrontView:)];
	tapGesture.delegate = self;
	[self.frontView addGestureRecognizer:tapGesture];
#if __has_feature(objc_arc)
#else
	[tapGesture release];
#endif
	
	self.frontView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.rearView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.learView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:self.learView];
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
	self.currentFrontViewPosition = FrontViewPositionCenter;
	
	[self _addLearViewControllerToHierarchy:self.learViewController];
	[self _addRearViewControllerToHierarchy:self.rearViewController];
	[self _addFrontViewControllerToHierarchy:self.frontViewController];
}

- (void)viewDidUnload
{
	[self _removeViewControllerFromHierarchy:self.frontViewController];
	[self _removeViewControllerFromHierarchy:self.rearViewController];
	[self _removeViewControllerFromHierarchy:self.learViewController];
	
	self.frontView = nil;
	self.rearView = nil;
	self.learView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	/* A bit dirty. See the definitions of the interface orientation masks to understand */
	return (_supportedInterfaceOrientations & (1 << toInterfaceOrientation));
}

- (NSUInteger)supportedInterfaceOrientations
{
	return _supportedInterfaceOrientations;
}

#pragma mark Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return (self.currentFrontViewPosition != FrontViewPositionCenter);
}

- (void)tapRecognizedOnFrontView:(UITapGestureRecognizer *)gestureRecognizer
{
	NSAssert(self.currentFrontViewPosition != FrontViewPositionCenter, @"***** INTERNAL ERROR: Got current front view position equal to center in tap recognizer");
	if (self.currentFrontViewPosition == FrontViewPositionLeft || self.currentFrontViewPosition == FrontViewPositionLeftMost)
		[self revealLearToggle:self];
	else
		[self revealRearToggle:self];
}

#pragma mark - Memory Management

#if __has_feature(objc_arc)
#else
- (void)dealloc
{
	[_frontViewController release], _frontViewController = nil;
	[_rearViewController release], _rearViewController = nil;
	[_frontView release], _frontView = nil;
	[_rearView release], _rearView = nil;
	[_learView release], _learView = nil;
	[super dealloc];
}
#endif

@end
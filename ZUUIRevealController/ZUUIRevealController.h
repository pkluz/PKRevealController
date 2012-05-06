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

#import <UIKit/UIKit.h>

// Required for the shadow, cast by the front view.
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	FrontViewPositionLeft,
	FrontViewPositionRight,
	FrontViewPositionRightMost
} FrontViewPosition;

@protocol ZUUIRevealControllerDelegate;

@interface ZUUIRevealController : UIViewController <UITableViewDelegate>

#pragma mark - Public Properties:
@property (strong, nonatomic) IBOutlet UIViewController *frontViewController;
@property (strong, nonatomic) IBOutlet UIViewController *rearViewController;
@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;
@property (assign, nonatomic) id<ZUUIRevealControllerDelegate> delegate;

// Defines how much of the rear view is shown.
@property (assign, nonatomic) CGFloat rearViewRevealWidth;

// Defines how much of an overdraw can occur when drawing further than 'rearViewRevealWidth'.
@property (assign, nonatomic) CGFloat maxRearViewRevealOverdraw;

// Defines the width of the rear views presentation mode.
@property (assign, nonatomic) CGFloat rearViewPresentationWidth;

// Leftmost point at which a reveal will be triggered if a user stops panning.
@property (assign, nonatomic) CGFloat revealViewTriggerWidth;

// Leftmost point at which a conceal will be triggered if a user stops panning.
@property (assign, nonatomic) CGFloat concealViewTriggerWidth;

// Velocity required for the controller to instantly toggle its state.
@property (assign, nonatomic) CGFloat quickFlickVelocity;

// Default duration for the revealToggle: animation.
@property (assign, nonatomic) NSTimeInterval toggleAnimationDuration;

// Defines the radius of the front view's shadow.
@property (assign, nonatomic) CGFloat frontViewShadowRadius;

#pragma mark - Public Methods:
- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController;
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer;
- (void)revealToggle:(id)sender;
- (void)revealToggle:(id)sender animationDuration:(NSTimeInterval)animationDuration;

- (void)setFrontViewController:(UIViewController *)frontViewController;
- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

- (void)hideFrontView;
- (void)showFrontViewCompletely:(BOOL)completely;

@end

#pragma mark - Delegate Protocol:
@protocol ZUUIRevealControllerDelegate<NSObject>

@optional

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController;
- (BOOL)revealController:(ZUUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController;

/* IMPORTANT: It is not guaranteed that 'didReveal...' will be called after 'willReveal...'! - DO NOT _under any circumstances_ make that assumption!
 */
- (void)revealController:(ZUUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController willSwapToFrontViewController:(UIViewController *)frontViewController;
- (void)revealController:(ZUUIRevealController *)revealController didSwapToFrontViewController:(UIViewController *)frontViewController;

#pragma mark New in 0.9.9
- (void)revealController:(ZUUIRevealController *)revealController willResignRearViewControllerPresentationMode:(UIViewController *)rearViewController;
- (void)revealController:(ZUUIRevealController *)revealController didResignRearViewControllerPresentationMode:(UIViewController *)rearViewController;

- (void)revealController:(ZUUIRevealController *)revealController willEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController;
- (void)revealController:(ZUUIRevealController *)revealController didEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController;

@end

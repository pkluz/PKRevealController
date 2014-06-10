/*
    PKRevealController > PKRevealController.h
    Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
 
    The MIT License (MIT)
 
    Copyright (c) 2013 Philip Kluz
 
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
 
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
 
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+PKRevealController.h"

typedef enum : NSUInteger
{
    PKRevealControllerShowsLeftViewControllerInPresentationMode     = 1,
    PKRevealControllerShowsLeftViewController                       = 2,
    PKRevealControllerShowsFrontViewController                      = 3,
    PKRevealControllerShowsRightViewController                      = 4,
    PKRevealControllerShowsRightViewControllerInPresentationMode    = 5
} PKRevealControllerState;

typedef enum : NSUInteger
{
    PKRevealControllerAnimationTypeStatic
} PKRevealControllerAnimationType;

typedef enum : NSUInteger
{
    PKRevealControllerTypeNone  = 0,
    PKRevealControllerTypeLeft  = 1,
    PKRevealControllerTypeRight = 2,
    PKRevealControllerTypeBoth  = (PKRevealControllerTypeLeft | PKRevealControllerTypeRight)
} PKRevealControllerType;

typedef void(^PKDefaultCompletionHandler)(BOOL finished);

FOUNDATION_EXTERN NSString * const PKRevealControllerAnimationDurationKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerAnimationCurveKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerAnimationTypeKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerAllowsOverdrawKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerQuickSwipeToggleVelocityKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerDisablesFrontViewInteractionKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey;
FOUNDATION_EXTERN NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey;

@protocol PKRevealing;

@interface PKRevealController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - Properties
/// The view controller displayed on top of the left and right ones.
@property (nonatomic, readwrite) UIViewController *frontViewController;

/// The view controller on the left.
@property (nonatomic, readwrite) UIViewController *leftViewController;

/// The view controller on the right.
@property (nonatomic, readwrite) UIViewController *rightViewController;

/// The gesture recognizer that is used to enable pan based reveal. By default this recognizer is added to the front view's container. Inactive and at your disposal if front view panning is disabled.
@property (nonatomic, readonly) UIPanGestureRecognizer *revealPanGestureRecognizer;

/// The gesture recognizer that is used to enable snap-back-on-tap if a rear view is shown and the user taps on the front view. By default this recognizer is added to the front view's container. Inactive and at your disposal if front view tapping is disabled.
@property (nonatomic, readonly) UITapGestureRecognizer *revealResetTapGestureRecognizer;

/// The controllers current state. **Observable.**
@property (nonatomic, readonly) PKRevealControllerState state;

/// The view controller type. Deprecated because unnecessary. is -hasLeftViewController and hasRightViewController instead.
@property (nonatomic, readonly) PKRevealControllerType type __deprecated;

/// Returns YES if either the left or right view controller are revealed to thei max width.
@property (nonatomic, readonly) BOOL isPresentationModeActive;

/// Contains the controllers configuration. Deprecated in favour of direct property manipulation.
@property (nonatomic, readonly) NSDictionary *options __deprecated;

/// The controllers automatic reveal animation duration. Defaults to 0.185.
@property (nonatomic, assign, readwrite) CGFloat animationDuration;

/// The controllers automatic reveal animation curve. Defaults to UIViewAnimationCurveLinear.
@property (nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;

/// The controllers animation type. Currently only static is supported. Parallax and scaling support in the works.
@property (nonatomic, assign, readwrite) PKRevealControllerAnimationType animationType;

/// The minimum velocity required for a swipe to trigger a state change. Defaults to 800.
@property (nonatomic, assign, readwrite) CGFloat quickSwipeVelocity;

/// Whether to allow the user to draw further than the respective controllers min width. Dampened to stop at its max width. Defaults to YES.
@property (nonatomic, assign, readwrite) BOOL allowsOverdraw;

/// Whether to disable front view interaction whenever the controller's state does not equal PKRevealControllerShowsFrontViewController. Recommended for smaller screens.
@property (nonatomic, assign, readwrite) BOOL disablesFrontViewInteraction;

/// Whether to use the front view's entire visible area to allow pan based reveal.
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnFrontView;

/// Whether to allow snap-back-on-tap if a rear view is shown and the user taps on the front view.
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontView;

/// Whether to allow snap-back-on-tap if a rear view is shown in presentation mode and the user taps on the front view.
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontViewInPresentationMode;

/// The controller's delegate, conforming to the PKRevealing protocol.
@property (nonatomic, weak, readwrite) id<PKRevealing> delegate;

#pragma mark - Methods
/**
 Convenience initializer. Use if both left and right rear views are used.
 
 @param frontViewController The view controller displayed on top of the left and right ones.
 @param leftViewController The view controller on the left.
 @param rightViewController The view controller on the right.
 */
+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController;

/**
 Convenience initializer. Use if only left rear views is used.
 
 @param frontViewController The view controller displayed on top of the left and right ones.
 @param leftViewController The view controller on the left.
 */
+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController;

/**
 Convenience initializer. Use if only right rear views is used.
 
 @param frontViewController The view controller displayed on top of the left and right ones.
 @param rightViewController The view controller on the right.
 */
+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController;

/**
 Shifts the front view to the position that's best suited to present the desired controller's view. (Animates by default)
 
 @param controller This is either the left or the right view controller (if present - respectively).
 */
- (void)showViewController:(UIViewController *)controller;

/**
 Shifts the front view to the position that's best suited to present the desired controller's view.

 @param controller This is either the left or the right view controller (if present - respectively).
 @param animated Whether the position adjustments should be animated or not.
 @param completion Executed on the main thread after the show animation is completed.
 */
- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion;

/**
 Takes the currently active controller and enters presentation mode, thereby revealing the maximum width of the view.
 
 @param animated Whether the frame adjustments should be animated or not.
 @param completion Executed on the main thread after the show animation is completed.
 */
- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion;

/**
 If active, this method will resign the presentation mode.

 @param entirely By passing YES for this parameter, not only the presentation mode will resign, but the entire controller will go back to showing the front view only.
 @param animated Whether the frame adjustments should be animated or not.
 @param completion Executed on the main thread after the show animation is completed.
 */
- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion;

/**
 Exchanges the current front view controller for a new one.
 
 @param frontViewController Thew new front view controller.
 */
- (void)setFrontViewController:(UIViewController *)frontViewController;

/**
 Exchanges the current front view controller for a new one.
 
 Deprecated because unnecessary. Functionality can be reproduced by calling showViewController:animated:completion.

 @param frontViewController The new front view controller.
 @param focus Whether the front view controller's view animates back to its center position after it was set.
 @param completion Executed on the main thread after the show animation is completed.
 */
- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion __deprecated;

/**
 Exchanges the current left view controller for a new one.
 
 @param leftViewController Thew new left view controller.
 */
- (void)setLeftViewController:(UIViewController *)leftViewController;

/**
 Exchanges the current right view controller for a new one.
 
 @param rightViewController Thew new right view controller.
 */
- (void)setRightViewController:(UIViewController *)rightViewController;

/**
 Adjusts the minimum and maximum reveal width of any given view controller's view.
 
 @param minWidth The default (minimum) width of the view to be shown.
 @param maxWidth The maximum width of the view to be shown when overdrawing (if applicable) or entering presentation mode.
 @param controller The view controller whose view reveal sizing is being adjusted.
 */
- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller;

/**
 @return Returns the currently focused controller, i.e. the one that's most prominent at any given point in time.
 */
- (UIViewController *)focusedController;

/**
 @return Returns YES if the reveal controller has a right side, NO otherwise.
 */
- (BOOL)hasRightViewController;

/**
 @return BOOL - Returns YES if the reveal controller has a left side, NO otherwise.
 */
- (BOOL)hasLeftViewController;

@end

#pragma mark - PKRevealing Protocol Definition

@protocol PKRevealing <NSObject>

@optional
/**
 Implement this method to be notified whenever a state change WILL occur. I.e. this method is called whenever the user is about to change from showing the front view to revealing the left view etc.
 
 Please note: Abrupt changes are possible, which means the controller can go from PKRevealControllerShowsLeftViewController to PKRevealControllerShowsRightViewController without actually entering PKRevealControllerShowsFrontViewController. Do not make assumptions regarding the order!
 
 @param revealController The controller for which the state change will occur.
 @param state The state the controller will change to.
 */
- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)state;

/**
 Implement this method to be notified whenever a state change DID occur. I.e. this method is called whenever the user did change from showing the front view to revealing the left view etc.
 
 Please note: Abrupt changes are possible, which means the controller can go from PKRevealControllerShowsLeftViewController to PKRevealControllerShowsRightViewController without actually entering PKRevealControllerShowsFrontViewController. Do not make assumptions regarding the order!
 
 @param revealController The controller for which the state change did occur.
 @param state The state the controller did change to.
 */
- (void)revealController:(PKRevealController *)revealController didChangeToState:(PKRevealControllerState)state;

@end

#pragma mark - Deprecated as of 2.0.1

@interface PKRevealController (Deprecated)

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:leftViewController:rightViewController: instead. Set options using the options property.")));

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                                options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:leftViewController: instead. Set options using the options property.")));

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:rightViewController: instead. Set options using the options property.")));

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:leftViewController:rightViewController: instead. Set options using the options property.")));

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                                    options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:leftViewController: instead. Set options using the options property.")));

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options __attribute__((deprecated("Use +revealControllerWithFrontViewController:rightViewController: instead. Set options using the options property.")));

@end

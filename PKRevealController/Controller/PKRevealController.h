/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "PKRevealControllerType.h"
#import "UIViewController+PKRevealController.h"

typedef NS_ENUM(NSUInteger, PKRevealControllerState)
{
    PKRevealControllerFocusesLeftViewController,
    PKRevealControllerFocusesRightViewController,
    PKRevealControllerFocusesFrontViewController,
    PKRevealControllerFocusesLeftViewControllerInPresentationMode,
    PKRevealControllerFocusesRightViewControllerInPresentationMode
};

typedef NS_ENUM(NSUInteger, PKRevealControllerAnimationType)
{
    PKRevealControllerAnimationTypeStatic // Rear view's do not move at all.
};

@class PKRevealController;

@protocol PKRevealControllerDelegate <NSObject>

@optional

// Called when the reveal controller shows a new top view controller.
- (void)revealController:(PKRevealController *)revealController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@protocol PKRevealControllerAnimationDelegate <NSObject>

@optional

// Called when the reveal controller changes the visible width of the left view controller.
- (void)revealController:(PKRevealController *)revealController didChangeLeftViewControllerVisibleWidth:(CGFloat)width;

// Called when the reveal controller changes the visible width of the right view controller.
- (void)revealController:(PKRevealController *)revealController didChangeRightViewControllerVisibleWidth:(CGFloat)width;

@end

/*
 * List of notifications that are posted to the default NSNotificationCenter
 */

extern NSString * const PKRevealControllerDidShowFrontViewControllerNotification;
extern NSString * const PKRevealControllerDidShowLeftViewControllerNotification;
extern NSString * const PKRevealControllerDidShowRightViewControllerNotification;

/*
 * List of option keys that can be passed in the options dictionary.
 */

/*
 * Animation duration for automatic front view movement.
 *
 * @default 0.185sec
 * @value NSNumber containing an NSTimeInterval (double)
 */
extern NSString * const PKRevealControllerAnimationDurationKey;

/*
 * Animation curve for automatic front view movement.
 *
 * @default UIViewAnimationCurveLinear
 * @value NSNumber containing a UIViewAnimationCurve (NSUInteger)
 */
extern NSString * const PKRevealControllerAnimationCurveKey;

/*
 * The controller's animation type.
 *
 * @default PKRevealControllerAnimationTypeStatic
 * @value NSNumber containing a PKRevealControllerAnimationType (NSUInteger)
 */
extern NSString * const PKRevealControllerAnimationTypeKey;

/*
 * Determines whether an overdraw can take place. I.e. panning further than the views min-width.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerAllowsOverdrawKey;

/*
 * The minimum swipe velocity to trigger front view movement even if the actual min-threshold wasn't reached.
 *
 * @default 800.0f
 * @value NSNumber containing CGFloat
 */
extern NSString * const PKRevealControllerQuickSwipeToggleVelocityKey;

/*
 * Determines whether front view interaction is disabled while presenting a side view.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerDisablesFrontViewInteractionKey;

/*
 * Determines whether there's a UIPanGestureRecognizer placed over the entire front view, enabling pan-based reveal.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey;

/*
 * Determines whether there's a UIPanGestureRecognizer placed over the entire left view, enabling pan-based reveal closing.
 *
 * @default NO
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesPanningOnLeftViewKey;

/*
 * Determines whether there's a UIPanGestureRecognizer placed over the entire right view, enabling pan-based reveal closing.
 *
 * @default NO
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesPanningOnRightViewKey;

/*
 * Determines whether there's a UITapGestureRecognizer placed over the entire front view, when presenting
 * one of the side views to enable snap-back-on-tap functionality.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey;

/*
 * Determines the amount that the left view controller will slide with the front view controller movement.
 *
 * @default 0.0f
 * @value NSNumber containing float between 0.0f and 1.0f
 */
extern NSString * const PKRevealControllerLeftViewSlideAmountKey;

/*
 * Determines the amount that the right view controller will slide with the front view controller movement.
 *
 * @default 0.0f
 * @value NSNumber containing float between 0.0f and 1.0f
 */
extern NSString * const PKRevealControllerRightViewSlideAmountKey;


typedef void(^PKDefaultCompletionHandler)(BOOL finished);
typedef void(^PKDefaultErrorHandler)(NSError *error);

@interface PKRevealController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readonly) UIViewController *frontViewController;
@property (nonatomic, strong, readonly) UIViewController *leftViewController;
@property (nonatomic, strong, readonly) UIViewController *rightViewController;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *revealFrontPanGestureRecognizer;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *revealLeftPanGestureRecognizer;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *revealRightPanGestureRecognizer;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readonly) PKRevealControllerState state;
@property (nonatomic, assign, readonly) BOOL isPresentationModeActive;

@property (nonatomic, strong, readonly) NSDictionary *options;

@property (nonatomic, assign, readwrite) CGFloat animationDuration;
@property (nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property (nonatomic, assign, readwrite) PKRevealControllerAnimationType animationType;
@property (nonatomic, assign, readwrite) CGFloat quickSwipeVelocity;
@property (nonatomic, assign, readwrite) BOOL allowsOverdraw;
@property (nonatomic, assign, readwrite) BOOL disablesFrontViewInteraction;
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnFrontView;
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnLeftView;
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnRightView;
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontView;

@property (nonatomic, assign, readwrite) id<PKRevealControllerDelegate> delegate;

#pragma mark - Methods

/**
 * Initializers. Left/right controllers can be added/exchanged/removed dynamically after initialization.
 */
+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options;

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                                options:(NSDictionary *)options;

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options;

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options;

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
                          options:(NSDictionary *)options;

- (id)initWithFrontViewController:(UIViewController *)frontViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options;


/**
 * Shifts the front view to the position that's best suited to present the front controller's view. (Animates by default)
 */
- (void)showFrontViewController;

/**
 * Shifts the front view to the position that's best suited to present the left controller's view. (Animates by default)
 */
- (void)showLeftViewController;

/**
 * Shifts the front view to the position that's best suited to present the right controller's view. (Animates by default)
 */
- (void)showRightViewController;

/**
 * Shifts the front view to the position that's best suited to present the desired controller's view. (Animates by default)
 *
 * @param UIViewController controller - This is either the left or the right view controller (if present - respectively).
 */
- (void)showViewController:(UIViewController *)controller;

/**
 * Shifts the front view to the position that's best suited to present the desired controller's view.
 *
 * @param UIViewController controller - This is either the left or the right view controller (if present - respectively).
 * @param BOOL animated - Whether the frame adjustments should be animated or not.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the show animation is completed.
 */
- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion;

/**
 * Takes the currently active controller and enters presentation mode, thereby revealing the maximum width
 * of the view, which can be specified via the left/rightViewWidthRange properties.
 *
 * @param BOOL animated - Whether the frame adjustments should be animated or not.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the show animation is completed.
 */
- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion;

/**
 * If active, this method will resign the presentation mode.
 * 
 * @param BOOL entirely - By passing YES for this parameter, not only the presentation mode will resign, but the entire
 *                        controller will go back to showing the front view only.
 * @param BOOL animated - Whether the frame adjustments should be animated or not.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the show animation is completed.
 */
- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion;

/**
 * Exchanges the current front view controller for a new one.
 *
 * @param UIViewController frontViewController - Thew new front view controller.
 */
- (void)setFrontViewController:(UIViewController *)frontViewController;

/**
 * Exchanges the current front view controller for a new one.
 *
 * @param UIViewController frontViewController - The new front view controller.
 * @param BOOL focus - Whether the front view controller's view animates back to its center position after it was set.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the show animation is completed.
 */
- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion;

/**
 * Exchanges the current left view controller for a new one.
 *
 * @param UIViewController leftViewController - Thew new left view controller.
 */
- (void)setLeftViewController:(UIViewController *)leftViewController;

/**
 * Exchanges the current right view controller for a new one.
 *
 * @param UIViewController rightViewController - Thew new right view controller.
 */
- (void)setRightViewController:(UIViewController *)rightViewController;

/**
 * Adjusts the container shadow properties of a reveal side
 *
 * @param UIColor color - The color of the shadow (default black).
 * @param CGSize offset - The shadow offset (default CGSizeZero).
 * @param CGFloat opacity - The opacity of the shadow (default 0.5f).
 * @param CGFloat radius - The shadow's radius (default 2.5f).
 * @param PKRevealControllerType revealSide - The reveal side(s) on which the shadow will be adjusted.
 */
- (void)setShadowColor:(UIColor *)color
                offset:(CGSize)offset
               opacity:(CGFloat)opacity
                radius:(CGFloat)radius
         forRevealSide:(PKRevealControllerType)revealSide;

/**
 * Adjusts the minimum and maximum reveal width of any given view controller's view.
 *
 * @param CGFloat minWidth - The default (minimum) width of the view to be shown.
 * @param CGFloat minWidth - The maximum width of the view to be shown when overdrawing (if applicable) or
 *                           entering presentation mode.
 * @param UIViewController controller - The view controller whose view reveal sizing is being adjusted.
 */
- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller;

/**
 * @param UIViewController controller - The left or right view controller.
 *
 * @return CGFloat - The minimum width for the specified view controller. Returns 0 if the view controller is not recognized.
 */
- (CGFloat)minimumWidthForViewController:(UIViewController *)controller;

/**
 * @param UIViewController controller - The left or right view controller.
 *
 * @return CGFloat - The maximum width for the specified view controller. Returns 0 if the view controller is not recognized.
 */
- (CGFloat)maximumWidthForViewController:(UIViewController *)controller;

/**
 * @return UIViewController - Returns the currently focused controller, i.e. the one that's most prominent at any given point in time. 
 */
- (UIViewController *)focusedController;

/**
 * @return PKRevealControllerType - Returns the controller type, i.e. whether it has a left side, a right side, both or none.
 */
- (PKRevealControllerType)type;

/**
 * @return BOOL - Returns YES if the reveal controller has a right side, NO otherwise.
 */
- (BOOL)hasRightViewController;

/**
 * @return BOOL - Returns YES if the reveal controller has a left side, NO otherwise.
 */
- (BOOL)hasLeftViewController;

/**
 * @param PKRevealControllerAnimationDelegate delegate - Adds a delegate to receive notifications when reveal animations occur.
 */
- (void)addAnimationDelegate:(NSObject<PKRevealControllerAnimationDelegate> *)delegate;

/**
 * @param PKRevealControllerAnimationDelegate delegate - Removes a delegate from receiving notifications when reveal animations occur.
 */
- (void)removeAnimationDelegate:(NSObject<PKRevealControllerAnimationDelegate> *)delegate;

/**
 * Removes all reveal animation delegates.
 */
- (void)removeAllAnimationDelegates;

@end
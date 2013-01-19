/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "PKRevealController+Categories.h"

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
    PKRevealControllerAnimationTypeStatic
};

typedef NS_OPTIONS(NSUInteger, PKRevealControllerType)
{
    PKRevealControllerTypeNone,
    PKRevealControllerTypeLeft,
    PKRevealControllerTypeRight,
    PKRevealControllerTypeBoth = (PKRevealControllerTypeLeft | PKRevealControllerTypeRight)
};

/*
 * List of option keys that can be passed in the options dictionary.
 * See the key's descriptions for what their respective values are.
 */
extern NSString * const PKRevealControllerAnimationDurationKey;             // NSNumber containing CGFloat
extern NSString * const PKRevealControllerAnimationCurveKey;                // NSNumber containing NSInteger
extern NSString * const PKRevealControllerAnimationTypeKey;                 // NSNumber containing NSInteger
extern NSString * const PKRevealControllerAllowsOverdrawKey;                // NSNumber containing BOOL
extern NSString * const PKRevealControllerQuickSwipeToggleVelocityKey;      // NSNumber containing CGFloat
extern NSString * const PKRevealControllerDisablesFrontViewInteractionKey;  // NSNumber containing BOOL

typedef void(^PKDefaultCompletionHandler)(void);
typedef void(^PKDefaultErrorHandler)(NSError *error);

@interface PKRevealController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readonly) UIViewController *frontViewController;
@property (nonatomic, strong, readonly) UIViewController *leftViewController;
@property (nonatomic, strong, readonly) UIViewController *rightViewController;

@property (nonatomic, strong, readonly) NSDictionary *options;

@property (nonatomic, assign, readwrite) NSRange leftViewWidthRange;
@property (nonatomic, assign, readwrite) NSRange rightViewWidthRange;

@property (nonatomic, assign, readonly) PKRevealControllerState state;
@property (nonatomic, assign, readonly) BOOL isPresentationModeActive;

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
 * @param UIViewController frontViewController - Thew new front view controller.
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
 * Exchanges the current left view controller for a new one.
 *
 * @param UIViewController leftViewController - Thew new left view controller.
 * @param BOOL animated - Whether the addition/replacement should be animated. If YES is passed, the front view
 *                        will first animate to its center position, thereby concealing the sudden replacement
 *                        of the left view.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the animation is completed.
 */
- (void)setLeftViewController:(UIViewController *)leftViewController
                     animated:(BOOL)animated
                   completion:(PKDefaultCompletionHandler)completion;

/**
 * Exchanges the current right view controller for a new one.
 *
 * @param UIViewController rightViewController - Thew new right view controller.
 */
- (void)setRightViewController:(UIViewController *)rightViewController;

/**
 * Exchanges the current right view controller for a new one.
 *
 * @param UIViewController rightViewController - Thew new right view controller.
 * @param BOOL animated - Whether the addition/replacement should be animated. If YES is passed, the front view
 *                        will first animate to its center position, thereby concealing the sudden replacement
 *                        of the right view.
 * @param PKDefaultCompletionHandler completion - Executed on the main thread after the animation is completed.
 */
- (void)setRightViewController:(UIViewController *)rightViewController
                      animated:(BOOL)animated
                    completion:(PKDefaultCompletionHandler)completion;

/**
 * @return UIViewController - Returns the currently focused controller, i.e. the one that's most prominent at any given point in time. 
 */
- (UIViewController *)currentlyFocusedController;

/**
 * @return PKRevealControllerType - Returns the controller type, i.e. whether it has a left side, a right side, both or none.
 */
- (PKRevealControllerType)type;

@end
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
@property (nonatomic, readonly) UIViewController *frontViewController;
@property (nonatomic, readonly) UIViewController *leftViewController;
@property (nonatomic, readonly) UIViewController *rightViewController;
@property (nonatomic, readonly) UIPanGestureRecognizer *revealPanGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *revealResetTapGestureRecognizer;
@property (nonatomic, readonly) PKRevealControllerState state;
@property (nonatomic, readonly) PKRevealControllerType type __deprecated;
@property (nonatomic, readonly) BOOL isPresentationModeActive;
@property (nonatomic, readonly) NSDictionary *options;

@property (nonatomic, assign, readwrite) CGFloat animationDuration;
@property (nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property (nonatomic, assign, readwrite) PKRevealControllerAnimationType animationType;
@property (nonatomic, assign, readwrite) CGFloat quickSwipeVelocity;
@property (nonatomic, assign, readwrite) BOOL allowsOverdraw;
@property (nonatomic, assign, readwrite) BOOL disablesFrontViewInteraction;
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnFrontView;
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontView;
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontViewInPresentationMode;
@property (nonatomic, weak, readwrite) id<PKRevealing> delegate;


#pragma mark - Methods
+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController;

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController;

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController;

- (void)showViewController:(UIViewController *)controller;
- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion;

- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion;
- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion;

- (void)setFrontViewController:(UIViewController *)frontViewController;
- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion __deprecated;
- (void)setLeftViewController:(UIViewController *)leftViewController;
- (void)setRightViewController:(UIViewController *)rightViewController;

- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller;

- (UIViewController *)focusedController;

- (BOOL)hasRightViewController;
- (BOOL)hasLeftViewController;

@end

#pragma mark - PKRevealing Protocol Definition

@protocol PKRevealing <NSObject>

@optional
- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)state;
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

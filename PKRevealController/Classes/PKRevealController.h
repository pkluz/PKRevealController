/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, PKRevealControllerState)
{
    PKRevealControllerShowsLeftViewController,
    PKRevealControllerShowsRightViewController,
    PKRevealControllerShowsFrontViewController
};

typedef NS_OPTIONS(NSUInteger, PKRevealControllerType)
{
    PKRevealControllerTypeUndefined,
    PKRevealControllerTypeLeft,
    PKRevealControllerTypeRight,
    PKRevealControllerTypeBoth = (PKRevealControllerTypeLeft | PKRevealControllerTypeRight)
};

extern NSString * const PKRevealControllerAnimationDurationKey;
extern NSString * const PKRevealControllerAnimationCurveKey;
extern NSString * const PKRevealControllerLeftViewWidthRangeKey;
extern NSString * const PKRevealControllerRightViewWidthRangeKey;

typedef void(^PKDefaultCompletionHandler)(BOOL finished);
typedef void(^PKDefaultErrorHandler)(NSError *error);

@interface PKRevealController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readonly) UIViewController *frontViewController;
@property (nonatomic, strong, readonly) UIViewController *leftViewController;
@property (nonatomic, strong, readonly) UIViewController *rightViewController;
@property (nonatomic, assign, readonly) PKRevealControllerState state;

#pragma mark - Methods
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

- (void)showViewController:(UIViewController *)controller;
- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion;

- (void)setFrontViewController:(UIViewController *)frontViewController;
- (void)setFrontViewController:(UIViewController *)frontViewController
                      animated:(BOOL)animated showAfterChange:(BOOL)show
                    completion:(PKDefaultCompletionHandler)completion;

- (void)setLeftViewController:(UIViewController *)leftViewController;
- (void)setRightViewController:(UIViewController *)rightViewController;

- (UIViewController *)currentlyActiveController;

- (PKRevealControllerType)type;

@end
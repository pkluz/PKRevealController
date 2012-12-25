/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKRevealController.h"

#define DEFAULT_ANIMATION_DURATION_VALUE 0.2f
#define DEFAULT_ANIMATION_CURVE_VALUE UIViewAnimationCurveEaseInOut

#define DEFAULT_LEFT_VIEW_WIDTH_RANGE NSMakeRange(280, 300)
#define DEFAULT_RIGHT_VIEW_WIDTH_RANGE DEFAULT_LEFT_VIEW_WIDTH_RANGE

#define MIN_TRANSLATION_TO_TRIGGER_VIEW_CHANGE 40.0f

#define MIN_VELOCITY_TO_TRIGGER_INSTANT_VIEW_CHANGE 400.0f

@interface PKRevealController ()

#pragma mark - Properties
@property (nonatomic, assign, readwrite) PKRevealControllerState state;

@property (nonatomic, strong, readwrite) UIViewController *frontViewController;
@property (nonatomic, strong, readwrite) UIViewController *leftViewController;
@property (nonatomic, strong, readwrite) UIViewController *rightViewController;
@property (nonatomic, strong, readwrite) NSDictionary *options;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign, readwrite) CGPoint initialTouchLocation;
@property (nonatomic, assign, readwrite) CGPoint previousTouchLocation;

@end

@implementation PKRevealController

NSString * const PKRevealControllerAnimationDurationKey = @"PKRevealControllerAnimationDurationKey";
NSString * const PKRevealControllerAnimationCurveKey = @"PKRevealControllerAnimationCurveKey";
NSString * const PKRevealControllerLeftViewWidthRangeKey = @"PKRevealControllerLeftViewWidthRangeKey";
NSString * const PKRevealControllerRightViewWidthRangeKey = @"PKRevealControllerRightViewWidthRangeKey";

#pragma mark - Initialization

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                         rightViewController:rightViewController
                                                     options:options];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                                     options:options];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                         rightViewController:rightViewController
                                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
                          options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:leftViewController
                         rightViewController:nil
                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:nil
                         rightViewController:rightViewController
                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options
{
    self = [super init];
    
    if (self != nil)
    {
        [self commonInitializer];
        
        self.frontViewController = frontViewController;
        self.leftViewController = leftViewController;
        self.rightViewController = rightViewController;
        
        self.options = options;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (void)commonInitializer
{
    self.state = PKRevealControllerShowsFrontViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    [self setupPanGestureRecognizer];
    [self setupTapGestureRecognizer];
}

#pragma mark - Setup

- (void)setup
{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
}

- (void)setupFrontViewShadow
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.frontViewController.view.bounds];
    self.frontViewController.view.layer.masksToBounds = NO;
    self.frontViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.frontViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.frontViewController.view.layer.shadowOpacity = 0.65f;
    self.frontViewController.view.layer.shadowRadius = 2.5f;
    self.frontViewController.view.layer.shadowPath = shadowPath.CGPath;
}

- (void)setupPanGestureRecognizer
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizePanWithGestureRecognizer:)];
    self.panGestureRecognizer.delegate = self;
}

- (void)setupTapGestureRecognizer
{
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapWithGestureRecognizer:)];
    self.tapGestureRecognizer.delegate = self;
}

#pragma mark - Options

- (CGFloat)animationDuration
{
    NSNumber *animationDurationNumber = [self.options objectForKey:PKRevealControllerAnimationDurationKey];
    
    if (animationDurationNumber != nil)
    {
        return [animationDurationNumber floatValue];
    }
    
    return DEFAULT_ANIMATION_DURATION_VALUE;
}

- (UIViewAnimationCurve)animationCurve
{
    NSNumber *animationCurveNumber = [self.options objectForKey:PKRevealControllerAnimationCurveKey];
    
    if (animationCurveNumber != nil)
    {
        return [animationCurveNumber integerValue];
    }
    
    return DEFAULT_ANIMATION_CURVE_VALUE;
}

- (NSRange)leftViewWidthRange
{
    NSValue *range = [self.options objectForKey:PKRevealControllerLeftViewWidthRangeKey];
    
    if (range != nil)
    {
        return [range rangeValue];
    }
    
    return DEFAULT_LEFT_VIEW_WIDTH_RANGE;
}

- (NSRange)rightViewWidthRange
{
    NSValue *range = [self.options objectForKey:PKRevealControllerRightViewWidthRangeKey];
    
    if (range != nil)
    {
        return [range rangeValue];
    }
    
    return DEFAULT_RIGHT_VIEW_WIDTH_RANGE;
}

#pragma mark - API

- (void)showViewController:(UIViewController *)controller
{
    [self showViewController:controller animated:NO completion:NULL];
}

- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion
{
    if (controller == self.leftViewController)
    {
        [self hasLeftViewController] ? [self showLeftViewControllerAnimated:animated completion:completion] : nil;
    }
    else if (controller == self.rightViewController)
    {
        [self hasRightViewController] ? [self showRightViewControllerAnimated:animated completion:completion] : nil;
    }
    else if (controller == self.frontViewController)
    {
        [self showFrontViewControllerAnimated:animated completion:completion];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
    [self setFrontViewController:frontViewController animated:NO showAfterChange:NO completion:NULL];
}

- (void)setFrontViewController:(UIViewController *)frontViewController
                      animated:(BOOL)animated
               showAfterChange:(BOOL)show
                    completion:(PKDefaultCompletionHandler)completion
{
    if (_frontViewController != frontViewController)
    {
        [self removeFrontViewController];
        
        _frontViewController = frontViewController;
        
        [self addFrontViewController];
        
        show ? [self showViewController:self.frontViewController animated:animated completion:completion]
             : (completion != NULL) ? completion(YES) : nil;
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    BOOL isLeftViewVisible = (self.state == PKRevealControllerShowsLeftViewController);
    
    if (_leftViewController != leftViewController)
    {
        isLeftViewVisible ? [self removeLeftViewController] : nil;
        
        _leftViewController = leftViewController;
        
        isLeftViewVisible ? [self addLeftViewController] : nil;
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    BOOL isRightViewVisible = (self.state == PKRevealControllerShowsRightViewController);
    
    if (_rightViewController != rightViewController)
    {
        isRightViewVisible ? [self removeRightViewController] : nil;
        
        _rightViewController = rightViewController;
        
        isRightViewVisible ? [self addRightViewController] : nil;
    }
}

- (PKRevealControllerType)type
{
    if (self.frontViewController != nil && self.leftViewController != nil && self.rightViewController != nil)
    {
        return PKRevealControllerTypeBoth;
    }
    else if (self.frontViewController != nil && self.leftViewController != nil)
    {
        return PKRevealControllerTypeLeft;
    }
    else if (self.frontViewController != nil && self.rightViewController != nil)
    {
        return PKRevealControllerTypeRight;
    }
    
    return PKRevealControllerTypeUndefined;
}

- (UIViewController *)currentlyActiveController
{
    switch (self.state)
    {
        case PKRevealControllerShowsFrontViewController:
            return self.frontViewController;
            break;
            
        case PKRevealControllerShowsLeftViewController:
            return self.leftViewController;
            break;
            
        case PKRevealControllerShowsRightViewController:
            return self.rightViewController;
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - Gesture Recognition

- (void)didRecognizeTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self showViewController:self.frontViewController animated:YES completion:NULL];
}

- (void)didRecognizePanWithGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateChanged:
            [self handleGestureChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self handleGestureEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateBegan:
            [self handleGestureBeganWithRecognizer:recognizer];
            break;
                        
        default:
            break;
    }
}

#pragma mark - Gesture Handling

- (void)handleGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.initialTouchLocation = [recognizer locationInView:self.view];
    self.previousTouchLocation = self.initialTouchLocation;
    
    [self handleGestureChangedWithRecognizer:recognizer];
}

- (void)handleGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self.view];
    CGFloat delta = currentTouchLocation.x - self.previousTouchLocation.x;
    
    [self moveFrontViewBy:delta];
    [self adjustLeftAndRightViewVisibilities];
    
    self.previousTouchLocation = currentTouchLocation;
}

- (void)handleGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self.view];
    CGFloat absoluteDelta = currentTouchLocation.x - self.initialTouchLocation.x;

    if (isPositive(absoluteDelta) && absoluteDelta > MIN_TRANSLATION_TO_TRIGGER_VIEW_CHANGE)
    {
        [self moveFrontViewRightwardsIfPossible];
    }
    else if (isNegative(absoluteDelta) && absoluteDelta < -MIN_TRANSLATION_TO_TRIGGER_VIEW_CHANGE)
    {
        [self moveFrontViewLeftwardsIfPossible];
    }
    else
    {
        [self showViewController:[self currentlyActiveController] animated:YES completion:NULL];
    }
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer)
    {
        CGPoint translation = [self.panGestureRecognizer translationInView:self.frontViewController.view];
        return (fabs(translation.x) >= fabs(translation.y));
    }
    else if (gestureRecognizer == self.tapGestureRecognizer)
    {
        return (self.state == PKRevealControllerShowsLeftViewController || self.state == PKRevealControllerShowsRightViewController);
    }
    
    return YES;
}

#pragma mark - Internal

- (void)moveFrontViewBy:(CGFloat)delta
{
    CGRect frame = self.frontViewController.view.frame;
    CGRect frameForFrontViewCenter = [self frontViewFrameForCenter];
    CGFloat translation = CGRectGetMinX(frame)+delta;
    
    BOOL isPositiveTranslation = (translation > CGRectGetMinX(frameForFrontViewCenter));
    BOOL positiveTranslationDoesNotExceedSoftLimit = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewWidthRange].location);
    BOOL positiveTranslationDoesNotExceedHardLimit = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewWidthRange].length);
    
    BOOL isNegativeTranslation = (translation < CGRectGetMinX(frameForFrontViewCenter));
    BOOL negativeTranslationDoesNotExceedSoftLimit = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewWidthRange].location);
    BOOL negativeTranslationDoesNotExceedHardLimit = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewWidthRange].length);
    
    BOOL isLegalTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedSoftLimit)
                            || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedSoftLimit);
    
    BOOL isLegalOverdraw = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedHardLimit)
                        || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedHardLimit);
    
    if (isLegalTranslation)
    {
        frame.origin.x += delta;
    }
    else if (isLegalOverdraw)
    {
        frame.origin.x += delta;
    }
              
    self.frontViewController.view.frame = frame;
}

- (void)moveFrontViewRightwardsIfPossible
{
    if (self.state != PKRevealControllerShowsRightViewController)
    {
        [self showViewController:self.leftViewController animated:YES completion:NULL];
    }
    else
    {
        [self showViewController:self.frontViewController animated:YES completion:NULL];
    }
}

- (void)moveFrontViewLeftwardsIfPossible
{
    if (self.state == PKRevealControllerShowsLeftViewController)
    {
        [self showViewController:self.frontViewController animated:YES completion:NULL];
    }
    else
    {
        [self showViewController:self.rightViewController animated:YES completion:NULL];
    }
}

#pragma mark -

- (void)addFrontViewController
{
    if (self.frontViewController != nil && ![self.childViewControllers containsObject:self.frontViewController])
    {
        self.frontViewController.view.layer.cornerRadius = 3.0f;
        
        [self setupFrontViewShadow];
        
        [self addChildViewController:self.frontViewController];
        
        self.frontViewController.view.frame = [self frontViewFrameForCurrentState];
        
        self.frontViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self.view addSubview:self.frontViewController.view];
        
        [self.frontViewController didMoveToParentViewController:self];
        
        [self addTapGestureRecognizer];
        [self addPanGestureRecognizer];
    }
}

- (void)removeFrontViewController
{
    if ([self.childViewControllers containsObject:self.frontViewController])
    {
        [self.frontViewController.view removeFromSuperview];
        [self.frontViewController removeFromParentViewController];
        
        [self removeTapGestureRecognizer];
        [self removePanGestureRecognizer];
    }
}

- (void)addLeftViewController
{
    if (self.leftViewController != nil && ![self.childViewControllers containsObject:self.leftViewController])
    {
        [self removeRightViewController];
        
        [self addChildViewController:self.leftViewController];
        self.leftViewController.view.frame = self.view.bounds;
        [self.view insertSubview:self.leftViewController.view belowSubview:self.frontViewController.view];
        [self.leftViewController didMoveToParentViewController:self];
    }
}

- (void)removeLeftViewController
{
    if ([self.childViewControllers containsObject:self.leftViewController])
    {
        [self.leftViewController.view removeFromSuperview];
        [self.leftViewController removeFromParentViewController];
    }
}

- (void)addRightViewController
{
    if (self.rightViewController != nil && ![self.childViewControllers containsObject:self.rightViewController])
    {
        [self removeLeftViewController];
        
        [self addChildViewController:self.rightViewController];
        self.rightViewController.view.frame = self.view.bounds;
        [self.view insertSubview:self.rightViewController.view belowSubview:self.frontViewController.view];
        [self.rightViewController didMoveToParentViewController:self];
    }
}

- (void)removeRightViewController
{
    if ([self.childViewControllers containsObject:self.rightViewController])
    {
        [self.rightViewController.view removeFromSuperview];
        [self.rightViewController removeFromParentViewController];
    }
}

- (void)addPanGestureRecognizer
{
    [self.frontViewController.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)removePanGestureRecognizer
{
    [self.frontViewController.view removeGestureRecognizer:self.panGestureRecognizer];
}

- (void)addTapGestureRecognizer
{
    [self.frontViewController.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)removeTapGestureRecognizer
{
    [self.frontViewController.view removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Helpers (Internal)

- (BOOL)hasLeftViewController
{
    return (self.type & PKRevealControllerTypeLeft);
}

- (BOOL)hasRightViewController
{
    return (self.type & PKRevealControllerTypeRight);
}

- (void)adjustLeftAndRightViewVisibilities
{
    CGPoint origin = self.frontViewController.view.frame.origin;
    (isPositive(origin.x)) ? [self addLeftViewController] : [self addRightViewController];
}

#pragma mark - Helper (Internal)

- (void)showLeftViewControllerAnimated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    [self addLeftViewController];
    
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForVisibleLeftView] animated:animated completion:^(BOOL finished)
    {
        self.state = PKRevealControllerShowsLeftViewController;
        (completion != NULL) ? completion(finished) : nil;
        
        [weakSelf removeRightViewController];
    }];
}


- (void)showRightViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    [self addRightViewController];
    
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForVisibleRightView] animated:animated completion:^(BOOL finished)
    {
        self.state = PKRevealControllerShowsRightViewController;
        (completion != NULL) ? completion(finished) : nil;
        
        [weakSelf removeLeftViewController];
    }];
}


- (void)showFrontViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForCenter] animated:animated completion:^(BOOL finished)
    {
        self.state = PKRevealControllerShowsFrontViewController;
        (completion != NULL) ? completion(finished) : nil;
        
        [weakSelf removeRightViewController];
        [weakSelf removeLeftViewController];
    }];
}

- (void)setFrontViewFrame:(CGRect)frame
                 animated:(BOOL)animated
               completion:(PKDefaultCompletionHandler)completion
{
    CGFloat duration = [self animationDuration];
    
    UIViewAnimationOptions options = (UIViewAnimationOptionBeginFromCurrentState | [self animationCurve]);
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
    {
        self.frontViewController.view.frame = frame;
    }
    completion:^(BOOL finished)
    {
        if (finished)
        {
            (completion != NULL) ? completion(finished) : nil;
        }
    }];
}

- (CGRect)frontViewFrameForCurrentState
{
    if (self.state == PKRevealControllerShowsFrontViewController)
    {
        return [self frontViewFrameForCenter];
    }
    else if (self.state == PKRevealControllerShowsLeftViewController)
    {
        return [self frontViewFrameForVisibleLeftView];
    }
    else if (self.state == PKRevealControllerShowsRightViewController)
    {
        return [self frontViewFrameForVisibleRightView];
    }
    
    return CGRectNull;
}

- (CGRect)frontViewFrameForVisibleLeftView
{
    CGFloat offset = [self leftViewWidthRange].location;
    return CGRectOffset([self frontViewFrameForCenter], offset, 0.0f);
}

- (CGRect)frontViewFrameForVisibleRightView
{
    CGFloat offset = [self rightViewWidthRange].location;
    return CGRectOffset([self frontViewFrameForCenter], -offset, 0.0f);
}

- (CGRect)frontViewFrameForCenter
{
    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(0.0f, 0.0f);
    return frame;
}

#pragma mark - Autorotation

/*
 * Please Note: The PKRevealController will only rotate if and only if all the controllers support the requested orientation.
 */
- (BOOL)shouldAutorotate
{
    if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate] && [self.leftViewController shouldAutorotate] && [self.rightViewController shouldAutorotate];
    }
    else if ([self hasLeftViewController])
    {
        return [self.frontViewController shouldAutorotate] && [self.leftViewController shouldAutorotate];
    }
    else if ([self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate] && [self.rightViewController shouldAutorotate];
    }
    else
    {
        return [self.frontViewController shouldAutorotate];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations & self.leftViewController.supportedInterfaceOrientations & self.rightViewController.supportedInterfaceOrientations;
    }
    else if ([self hasLeftViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations & self.leftViewController.supportedInterfaceOrientations;
    }
    else if ([self hasRightViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations & self.rightViewController.supportedInterfaceOrientations;
    }
    else
    {
        return self.frontViewController.supportedInterfaceOrientations;
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    [self.frontViewController removeFromParentViewController];
    [self.frontViewController.view removeFromSuperview];
    
    [self.leftViewController removeFromParentViewController];
    [self.leftViewController.view removeFromSuperview];
        
    [self.rightViewController removeFromParentViewController];
    [self.rightViewController.view removeFromSuperview];
}

#pragma mark - Helpers (Generic)

NS_INLINE BOOL isPositive(CGFloat value)
{
    return (value >= 0.0f);
}

NS_INLINE BOOL isNegative(CGFloat value)
{
    return (value < 0.0f);
}

@end
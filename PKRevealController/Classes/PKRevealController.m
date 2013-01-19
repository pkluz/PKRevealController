/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKRevealController.h"
#import "PKRevealControllerContainerView.h"

#define DEFAULT_ANIMATION_DURATION_VALUE 0.185f
#define DEFAULT_ANIMATION_CURVE_VALUE UIViewAnimationCurveLinear
#define DEFAULT_LEFT_VIEW_WIDTH_RANGE NSMakeRange(280, 310)
#define DEFAULT_RIGHT_VIEW_WIDTH_RANGE DEFAULT_LEFT_VIEW_WIDTH_RANGE
#define DEAULT_ALLOWS_OVERDRAW_VALUE NO
#define DEFAULT_ANIMATION_TYPE_VALUE PKRevealControllerAnimationTypeStatic
#define DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE 800.0f
#define DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE YES

@interface PKRevealController ()

#pragma mark - Properties
@property (nonatomic, assign, readwrite) PKRevealControllerState state;
@property (nonatomic, assign, readwrite) BOOL isPresentationModeActive;

@property (nonatomic, strong, readwrite) UIViewController *frontViewController;
@property (nonatomic, strong, readwrite) UIViewController *leftViewController;
@property (nonatomic, strong, readwrite) UIViewController *rightViewController;

@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *frontViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *leftViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *rightViewContainer;

@property (nonatomic, strong, readwrite) NSDictionary *options;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readwrite) CGPoint initialTouchLocation;
@property (nonatomic, assign, readwrite) CGPoint previousTouchLocation;

@property (nonatomic, assign, readwrite) CGFloat animationDuration;
@property (nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property (nonatomic, assign, readwrite) PKRevealControllerAnimationType animationType;
@property (nonatomic, assign, readwrite) BOOL allowsOverdraw;
@property (nonatomic, assign, readwrite) BOOL disablesFrontViewInteraction;
@property (nonatomic, assign, readwrite) CGFloat quickSwipeVelocity;

@property (nonatomic, assign, readwrite) CGFloat overdrawAccumulator;

@end

@implementation PKRevealController

NSString * const PKRevealControllerAnimationDurationKey = @"PKRevealControllerAnimationDurationKey";
NSString * const PKRevealControllerAnimationCurveKey = @"PKRevealControllerAnimationCurveKey";
NSString * const PKRevealControllerAnimationTypeKey = @"PKRevealControllerAnimationTypeKey";
NSString * const PKRevealControllerAllowsOverdrawKey = @"PKRevealControllerAllowsOverdrawKey";
NSString * const PKRevealControllerQuickSwipeToggleVelocityKey = @"PKRevealControllerQuickSwipeToggleVelocityKey";
NSString * const PKRevealControllerDisablesFrontViewInteractionKey = @"PKRevealControllerDisablesFrontViewInteractionKey";

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
    self.state = PKRevealControllerFocusesFrontViewController;
    self.leftViewWidthRange = DEFAULT_LEFT_VIEW_WIDTH_RANGE;
    self.rightViewWidthRange = DEFAULT_RIGHT_VIEW_WIDTH_RANGE;
}

#pragma mark - API

- (void)showViewController:(UIViewController *)controller
{
    [self showViewController:controller animated:YES completion:NULL];
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


- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion;
{
    if (self.state == PKRevealControllerFocusesLeftViewController)
    {
        [self enterPresentationModeForLeftViewControllerAnimated:animated completion:completion];
    }
    else if (self.state == PKRevealControllerFocusesRightViewController)
    {
        [self enterPresentationModeForRightViewControllerAnimated:animated completion:completion];
    }
}

- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    if (self.state == PKRevealControllerFocusesLeftViewControllerInPresentationMode)
    {
        [self resignPresentationModeForLeftViewControllerEntirely:entirely animated:animated completion:completion];
    }
    else if (self.state == PKRevealControllerFocusesRightViewControllerInPresentationMode)
    {
        [self resignPresentationModeForRightViewControllerEntirely:entirely animated:animated completion:completion];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
    if (_frontViewController != frontViewController)
    {
        [self removeFrontViewController];
        
        _frontViewController = frontViewController;
        _frontViewController.revealController = self;
        
        [self addFrontViewController];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion
{
    [self setFrontViewController:frontViewController];
    
    if (focus && self.state != PKRevealControllerFocusesFrontViewController)
    {
        [self showViewController:self.frontViewController];
    }
    
    safelyExecuteCompletionBlock(completion);
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    BOOL isLeftViewVisible = (self.state == PKRevealControllerFocusesLeftViewController);
    
    if (_leftViewController != leftViewController)
    {
        if (isLeftViewVisible)
        {
            [self removeLeftViewController];
        }
        
        _leftViewController = leftViewController;
        _leftViewController.revealController = self;
        
        if (isLeftViewVisible)
        {
            [self removeRightViewController];
            [self addLeftViewController];
        }
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
                     animated:(BOOL)animated
                   completion:(PKDefaultCompletionHandler)completion
{
    if (animated)
    {
        [self showViewController:self.frontViewController
                        animated:animated
                      completion:^(void)
        {
            [self setLeftViewController:leftViewController];
            safelyExecuteCompletionBlock(completion);
        }];
    }
    else
    {
        [self setLeftViewController:leftViewController];
        safelyExecuteCompletionBlock(completion);
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    BOOL isRightViewVisible = (self.state == PKRevealControllerFocusesRightViewController);
    
    if (_rightViewController != rightViewController)
    {
        if (isRightViewVisible)
        {
            [self removeRightViewController];
        }
        
        _rightViewController = rightViewController;
        _rightViewController.revealController = self;
        
        if (isRightViewVisible)
        {
            [self removeLeftViewController];
            [self addRightViewController];
        }
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
                      animated:(BOOL)animated
                    completion:(PKDefaultCompletionHandler)completion
{
    if (animated)
    {
        [self showViewController:self.frontViewController
                        animated:animated
                      completion:^(void)
        {
            [self setRightViewController:rightViewController];
            safelyExecuteCompletionBlock(completion);
        }];
    }
    else
    {
        [self setRightViewController:rightViewController];
        safelyExecuteCompletionBlock(completion);
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
    
    return PKRevealControllerTypeNone;
}

- (UIViewController *)currentlyFocusedController
{
    switch (self.state)
    {
        case PKRevealControllerFocusesFrontViewController:
            return self.frontViewController;
            break;
            
        case PKRevealControllerFocusesLeftViewController:
            return self.leftViewController;
            break;
            
        case PKRevealControllerFocusesRightViewController:
            return self.rightViewController;
            break;
            
        default:
            return nil;
            break;
    }
}

- (BOOL)isPresentationModeActive
{
    return (self.state == PKRevealControllerFocusesLeftViewControllerInPresentationMode
            || self.state == PKRevealControllerFocusesRightViewControllerInPresentationMode);
}

#pragma mark - View Lifecycle (System)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    [self setupPanGestureRecognizer];
    [self setupTapGestureRecognizer];
}

#pragma mark - View Lifecycle (Controller)

- (void)addFrontViewController
{
    if (![self.childViewControllers containsObject:self.frontViewController])
    {
        [self addChildViewController:self.frontViewController];
        [self.frontViewContainer prepareForReuseWithController:self.frontViewController];
        
        if (self.frontViewContainer == nil)
        {
            self.frontViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.frontViewController withShadow:YES];
            self.frontViewContainer.autoresizingMask = [self autoresizingMaskForFrontViewContainer];
        }
        
        self.frontViewContainer.frame = [self frontViewFrameForCurrentState];
        [self.view addSubview:self.frontViewContainer];
        [self.frontViewController didMoveToParentViewController:self];
        
        [self addTapGestureRecognizer];
        [self addPanGestureRecognizer];
    }
}

- (void)removeFrontViewController
{
    if ([self.childViewControllers containsObject:self.frontViewController])
    {
        [self.frontViewContainer removeFromSuperview];
        [self.frontViewController removeFromParentViewController];
        
        [self removeTapGestureRecognizer];
        [self removePanGestureRecognizer];
    }
}

- (void)addLeftViewController
{
    if (![self.childViewControllers containsObject:self.leftViewController])
    {
        [self addChildViewController:self.leftViewController];
        [self.leftViewContainer prepareForReuseWithController:self.leftViewController];
        
        if (self.leftViewContainer == nil)
        {
            self.leftViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.leftViewController withShadow:NO];
            self.leftViewContainer.autoresizingMask = [self autoresizingMaskForLeftViewContainer];
        }
        
        self.leftViewContainer.frame = [self leftViewFrame];
        [self.view insertSubview:self.leftViewContainer belowSubview:self.frontViewContainer];
        [self.leftViewController didMoveToParentViewController:self];
    }
}

- (void)removeLeftViewController
{
    if ([self.childViewControllers containsObject:self.leftViewController])
    {
        [self.leftViewContainer removeFromSuperview];
        [self.leftViewController removeFromParentViewController];
    }
}

- (void)addRightViewController
{
    if (![self.childViewControllers containsObject:self.rightViewController])
    {
        [self addChildViewController:self.rightViewController];
        [self.rightViewContainer prepareForReuseWithController:self.rightViewController];
        
        if (self.rightViewContainer == nil)
        {
            self.rightViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.rightViewController withShadow:NO];
            self.rightViewContainer.autoresizingMask = [self autoresizingMaskForRightViewContainer];
        }
        
        self.rightViewContainer.frame = [self rightViewFrame];
        [self.view insertSubview:self.rightViewContainer belowSubview:self.frontViewContainer];
        [self.rightViewController didMoveToParentViewController:self];
    }
}

- (void)removeRightViewController
{
    if ([self.childViewControllers containsObject:self.rightViewController])
    {
        [self.rightViewContainer removeFromSuperview];
        [self.rightViewController removeFromParentViewController];
    }
}

- (void)addPanGestureRecognizer
{
    [self.frontViewContainer addGestureRecognizer:self.revealPanGestureRecognizer];
}

- (void)removePanGestureRecognizer
{
    [self.frontViewContainer removeGestureRecognizer:self.revealPanGestureRecognizer];
}

- (void)addTapGestureRecognizer
{
    [self.frontViewContainer addGestureRecognizer:self.revealResetTapGestureRecognizer];
}

- (void)removeTapGestureRecognizer
{
    [self.frontViewContainer removeGestureRecognizer:self.revealResetTapGestureRecognizer];
}

#pragma mark - Setup

- (void)setup
{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (void)setupPanGestureRecognizer
{
    self.revealPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didRecognizePanWithGestureRecognizer:)];
    self.revealPanGestureRecognizer.delegate = self;
}

- (void)setupTapGestureRecognizer
{
    self.revealResetTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didRecognizeTapWithGestureRecognizer:)];
    self.revealResetTapGestureRecognizer.delegate = self;
}

#pragma mark - Options

- (void)setOptions:(NSDictionary *)options
{
    if (_options != options)
    {
        _options = options;
    }
    
    [self updateConfigurationWithNewOptions];
}

- (void)updateConfigurationWithNewOptions
{
    self.animationDuration = [self extractAnimationDurationFromOptions];
    self.animationCurve = [self extractAnimationCurveFromOptions];
    self.animationType = [self extractAnimationTypeFromOptions];
    self.allowsOverdraw = [self extractAllowsOverdrawFromOptions];
    self.quickSwipeVelocity = [self extractQuickSwipeToggleVelocityFromOptions];
    self.disablesFrontViewInteraction = [self extractDisablesFrontViewInteractionFromOptions];
}

#pragma mark -

- (CGFloat)extractAnimationDurationFromOptions
{
    NSNumber *animationDurationNumber = [self.options objectForKey:PKRevealControllerAnimationDurationKey];
    
    if (animationDurationNumber != nil)
    {
        return [animationDurationNumber floatValue];
    }
    
    return DEFAULT_ANIMATION_DURATION_VALUE;
}

- (UIViewAnimationCurve)extractAnimationCurveFromOptions
{
    NSNumber *animationCurveNumber = [self.options objectForKey:PKRevealControllerAnimationCurveKey];
    
    if (animationCurveNumber != nil)
    {
        return (UIViewAnimationCurve)[animationCurveNumber integerValue];
    }
    
    return DEFAULT_ANIMATION_CURVE_VALUE;
}

- (PKRevealControllerAnimationType)extractAnimationTypeFromOptions
{
    NSNumber *animationType = [self.options objectForKey:PKRevealControllerAnimationTypeKey];
    
    if (animationType != nil)
    {
        return (PKRevealControllerAnimationType)[animationType integerValue];
    }
    
    return DEFAULT_ANIMATION_TYPE_VALUE;
}

- (BOOL)extractAllowsOverdrawFromOptions
{
    NSNumber *allowsOverdraw = [self.options objectForKey:PKRevealControllerAllowsOverdrawKey];
    
    if (allowsOverdraw != nil)
    {
        return [allowsOverdraw boolValue];
    }
    
    return DEAULT_ALLOWS_OVERDRAW_VALUE;
}

- (CGFloat)extractQuickSwipeToggleVelocityFromOptions
{
    NSNumber *quickSwipeVelocity = [self.options objectForKey:PKRevealControllerQuickSwipeToggleVelocityKey];
    
    if (quickSwipeVelocity != nil)
    {
        return [quickSwipeVelocity floatValue];
    }
    
    return DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE;
}

- (CGFloat)extractDisablesFrontViewInteractionFromOptions
{
    NSNumber *interactionDisabled = [self.options objectForKey:PKRevealControllerDisablesFrontViewInteractionKey];
    
    if (interactionDisabled != nil)
    {
        return [interactionDisabled boolValue];
    }
    
    return DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE;
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
            [self handleGestureChangedWithRecognizer:recognizer];
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
    
    [self translateViewsBy:delta animationType:[self animationType]];
    [self adjustLeftAndRightViewVisibilities];
    
    self.previousTouchLocation = currentTouchLocation;
}

- (void)handleGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.overdrawAccumulator = 0.0f;
    
    CGFloat velocity = [recognizer velocityInView:self.view].x;
    
    UIViewController *controllerToShow = nil;
    
    if (fabsf(velocity) > self.quickSwipeVelocity)
    {
        if (isPositive(velocity))
        {
            [self moveFrontViewRightwardsIfPossible];
        }
        else
        {
            [self moveFrontViewLeftwardsIfPossible];

        }
        
        return;
    }
    else
    {
        if ([self isLeftViewVisible])
        {
            BOOL showLeftView = CGRectGetWidth(CGRectIntersection(self.frontViewContainer.frame, self.leftViewContainer.frame)) <= CGRectGetMidX(self.leftViewContainer.bounds);
            controllerToShow = showLeftView ? self.leftViewController : self.frontViewController;
        }
        else if ([self isRightViewVisible])
        {
            BOOL showRightView = CGRectGetWidth(CGRectIntersection(self.frontViewContainer.frame, self.rightViewContainer.frame)) <= CGRectGetMidX(self.rightViewContainer.bounds);
            controllerToShow = showRightView ? self.rightViewController : self.frontViewController;
        }
        else
        {
            controllerToShow = self.frontViewController;
        }
    }
    
    [self showViewController:controllerToShow animated:YES completion:NULL];
}

#pragma mark - Gesture Delegation

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.revealPanGestureRecognizer)
    {
        CGPoint translation = [self.revealPanGestureRecognizer translationInView:self.frontViewContainer];
        return (fabs(translation.x) >= fabs(translation.y));
    }
    else if (gestureRecognizer == self.revealResetTapGestureRecognizer)
    {
        return (self.state == PKRevealControllerFocusesLeftViewController
                || self.state == PKRevealControllerFocusesRightViewController);
    } 
    
    return YES;
}

#pragma mark - Translation

- (void)translateViewsBy:(CGFloat)delta animationType:(PKRevealControllerAnimationType)animationType
{
    CGRect frame = self.frontViewContainer.frame;
    CGRect frameForFrontViewCenter = [self frontViewFrameForCenter];
    CGFloat translation = CGRectGetMinX(frame)+delta;
    
    BOOL isPositiveTranslation = (translation > CGRectGetMinX(frameForFrontViewCenter));
    BOOL positiveTranslationDoesNotExceedSoftLimit = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMinWidth]);
    BOOL positiveTranslationDoesNotExceedHardLimit = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMaxWidth]);
    
    BOOL isNegativeTranslation = (translation < CGRectGetMinX(frameForFrontViewCenter));
    BOOL negativeTranslationDoesNotExceedSoftLimit = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMinWidth]);
    BOOL negativeTranslationDoesNotExceedHardLimit = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMaxWidth]);
    
    BOOL isLegalNormalTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedSoftLimit)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedSoftLimit);
    
    BOOL isLegalOverdrawTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedHardLimit)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedHardLimit);
    
    if (isLegalNormalTranslation || isLegalOverdrawTranslation)
    {
        BOOL isOverdrawing = (!isLegalNormalTranslation && isLegalOverdrawTranslation);
        
        if (animationType == PKRevealControllerAnimationTypeStatic)
        {
            [self staticTranslationForViewsBy:delta isOverdrawing:isOverdrawing];
        }
    }
}

- (void)staticTranslationForViewsBy:(CGFloat)delta isOverdrawing:(BOOL)overdraw
{
    CGRect frame = self.frontViewContainer.frame;
    
    if (overdraw && self.allowsOverdraw)
    {
        frame.origin.x = frame.origin.x + (delta / 2.0f);
    }
    else if (!overdraw)
    {
        frame.origin.x += delta;
    }
    
    self.frontViewContainer.frame = CGRectIntegral(frame);
}

- (void)moveFrontViewRightwardsIfPossible
{
    if (self.state == PKRevealControllerFocusesRightViewController || self.state == PKRevealControllerFocusesRightViewControllerInPresentationMode)
    {
        [self showViewController:self.frontViewController animated:YES completion:NULL];
    }
    else
    {
        [self showViewController:self.leftViewController animated:YES completion:NULL];
    }
}

- (void)moveFrontViewLeftwardsIfPossible
{
    if (self.state == PKRevealControllerFocusesLeftViewController || self.state == PKRevealControllerFocusesLeftViewControllerInPresentationMode)
    {
        [self showViewController:self.frontViewController animated:YES completion:NULL];
    }
    else
    {
        [self showViewController:self.rightViewController animated:YES completion:NULL];
    }
}

#pragma mark - Helper (Internal)

- (void)showLeftViewControllerAnimated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    [self removeRightViewController];
    [self addLeftViewController];
    
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForVisibleLeftView]
                   animated:animated
                 completion:^(void)
     {
         weakSelf.disablesFrontViewInteraction ? [weakSelf.frontViewContainer disableUserInteractionForContainedView] : nil;
         weakSelf.state = PKRevealControllerFocusesLeftViewController;
         safelyExecuteCompletionBlock(completion);
         
         [weakSelf removeRightViewController];
     }];
}


- (void)showRightViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    [self removeLeftViewController];
    [self addRightViewController];
    
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForVisibleRightView]
                   animated:animated
                 completion:^(void)
     {
         weakSelf.disablesFrontViewInteraction ? [weakSelf.frontViewContainer disableUserInteractionForContainedView] : nil;
         weakSelf.state = PKRevealControllerFocusesRightViewController;
         safelyExecuteCompletionBlock(completion);
         
         [weakSelf removeLeftViewController];
     }];
}


- (void)showFrontViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForCenter]
                   animated:animated
                 completion:^(void)
     {
         weakSelf.disablesFrontViewInteraction ? [weakSelf.frontViewContainer enableUserInteractionForContainedView] : nil;
         weakSelf.state = PKRevealControllerFocusesFrontViewController;
         
         safelyExecuteCompletionBlock(completion);
         
         [weakSelf removeRightViewController];
         [weakSelf removeLeftViewController];
     }];
}

- (void)enterPresentationModeForLeftViewControllerAnimated:(BOOL)animated
                                                completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForLeftViewPresentationMode]
                   animated:animated
                 completion:^(void)
    {
        weakSelf.state = PKRevealControllerFocusesLeftViewControllerInPresentationMode;
        safelyExecuteCompletionBlock(completion);
    }];
}

- (void)enterPresentationModeForRightViewControllerAnimated:(BOOL)animated
                                                 completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForRightViewPresentationMode]
                   animated:animated
                 completion:^(void)
    {
        weakSelf.state = PKRevealControllerFocusesRightViewControllerInPresentationMode;
        safelyExecuteCompletionBlock(completion);
    }];
}

- (void)resignPresentationModeForLeftViewControllerEntirely:(BOOL)entirely
                                                   animated:(BOOL)animated
                                                 completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    CGRect frame;
    PKRevealControllerState state;
    
    if (entirely)
    {
        frame = [self frontViewFrameForCenter];
        state = PKRevealControllerFocusesFrontViewController;
    }
    else
    {
        frame = [self frontViewFrameForVisibleLeftView];
        state = PKRevealControllerFocusesLeftViewController;
    }
    
    [self setFrontViewFrame:frame
                   animated:animated
                 completion:^(void)
    {
        weakSelf.state = state;
        safelyExecuteCompletionBlock(completion);
    }];
}

- (void)resignPresentationModeForRightViewControllerEntirely:(BOOL)entirely
                                                    animated:(BOOL)animated
                                                  completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    CGRect frame;
    PKRevealControllerState state;
    
    if (entirely)
    {
        frame = [self frontViewFrameForCenter];
        state = PKRevealControllerFocusesFrontViewController;
    }
    else
    {
        frame = [self frontViewFrameForVisibleRightView];
        state = PKRevealControllerFocusesRightViewController;
    }
    
    [self setFrontViewFrame:frame
                   animated:animated
                 completion:^(void)
    {
        weakSelf.state = state;
        safelyExecuteCompletionBlock(completion);
    }];
}

#pragma mark -

- (void)setFrontViewFrame:(CGRect)frame
                 animated:(BOOL)animated
               completion:(PKDefaultCompletionHandler)completion
{
    CGFloat duration = [self animationDuration];
    UIViewAnimationOptions options = (UIViewAnimationOptionBeginFromCurrentState | [self animationCurve]);
    
    if (self.animationType == PKRevealControllerAnimationTypeStatic)
    {
        [self setFrontViewFrameLinearly:frame animated:animated duration:duration options:options completion:completion];
    }
}

- (void)setFrontViewFrameLinearly:(CGRect)frame
                         animated:(BOOL)animated
                         duration:(CGFloat)duration
                          options:(UIViewAnimationOptions)options
                       completion:(PKDefaultCompletionHandler)completion
{
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.frontViewContainer.frame = frame;
     }
                     completion:^(BOOL finished)
     {
         safelyExecuteCompletionBlock(completion);
     }];
}

#pragma mark - Helpers (States)

- (BOOL)hasLeftViewController
{
    return (self.type & PKRevealControllerTypeLeft);
}

- (BOOL)hasRightViewController
{
    return (self.type & PKRevealControllerTypeRight);
}

- (BOOL)isLeftViewVisible
{
    return isPositive(CGRectGetMinX(self.frontViewContainer.frame));
}

- (BOOL)isRightViewVisible
{
    return isNegative(CGRectGetMinX(self.frontViewContainer.frame));
}

- (BOOL)isFrontViewEntirelyVisible
{
    return isZero(CGRectGetMinX(self.frontViewContainer.frame));
}

- (void)adjustLeftAndRightViewVisibilities
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isPositive(origin.x))
    {
        [self removeRightViewController];
        [self addLeftViewController];
    }
    else
    {
        [self removeLeftViewController];
        [self addRightViewController];
    }
}

#pragma mark - Helper (Sizing)

- (CGFloat)leftViewMaxWidth
{
    return self.allowsOverdraw ? self.leftViewWidthRange.length : [self leftViewMinWidth];
}

- (CGFloat)rightViewMaxWidth
{
    return self.allowsOverdraw ? self.rightViewWidthRange.length : [self rightViewMinWidth];
}

- (CGFloat)leftViewMinWidth
{
    return self.leftViewWidthRange.location;
}

- (CGFloat)rightViewMinWidth
{
    return self.rightViewWidthRange.location;
}

#pragma mark - Helper (Frames)

- (CGRect)frontViewFrameForCurrentState
{
    if (self.state == PKRevealControllerFocusesFrontViewController)
    {
        return [self frontViewFrameForCenter];
    }
    else if (self.state == PKRevealControllerFocusesLeftViewController)
    {
        return [self frontViewFrameForVisibleLeftView];
    }
    else if (self.state == PKRevealControllerFocusesRightViewController)
    {
        return [self frontViewFrameForVisibleRightView];
    }
    
    return CGRectNull;
}

- (CGRect)frontViewFrameForVisibleLeftView
{
    CGFloat offset = [self leftViewMinWidth];
    return CGRectOffset([self frontViewFrameForCenter], offset, 0.0f);
}

- (CGRect)frontViewFrameForVisibleRightView
{
    CGFloat offset = [self rightViewMinWidth];
    return CGRectOffset([self frontViewFrameForCenter], -offset, 0.0f);
}

- (CGRect)frontViewFrameForCenter
{
    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(0.0f, 0.0f);
    return frame;
}

- (CGRect)frontViewFrameForLeftViewPresentationMode
{
    CGRect frame = [self frontViewFrameForCenter];
    frame.origin.x = [self leftViewMaxWidth];
    return frame;
}

- (CGRect)frontViewFrameForRightViewPresentationMode
{
    CGRect frame = [self frontViewFrameForCenter];
    frame.origin.x = -[self rightViewMaxWidth];
    return frame;
}

- (CGRect)leftViewFrame
{
    CGRect frame = CGRectZero;
    
    frame.size = CGSizeMake([self leftViewMaxWidth], CGRectGetHeight(self.view.bounds));
    frame.origin = CGPointZero;
    
    return frame;
}

- (CGRect)rightViewFrame
{
    CGRect frame = self.frontViewContainer.bounds;
    
    
    if (self.animationType == PKRevealControllerAnimationTypeStatic)
    {
        frame.size = CGSizeMake([self rightViewMaxWidth], CGRectGetHeight(self.view.bounds));
        frame.origin.x = CGRectGetWidth(self.frontViewContainer.bounds)-CGRectGetWidth(frame);
        frame.origin.y = 0.0f;
    }
    
    return frame;
}

#pragma mark - Helper (Autoresizing)

- (UIViewAutoresizing)autoresizingMaskForFrontViewContainer
{
    return (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (UIViewAutoresizing)autoresizingMaskForLeftViewContainer
{
    return (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin);
}

- (UIViewAutoresizing)autoresizingMaskForRightViewContainer
{
    return (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);
}

#pragma mark - Autorotation

/*
 * Please Note: The PKRevealController will only rotate if, and only if,
 * all the controllers support the requested orientation.
 */
- (BOOL)shouldAutorotate
{
    if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate]
            && [self.leftViewController shouldAutorotate]
            && [self.rightViewController shouldAutorotate];
    }
    else if ([self hasLeftViewController])
    {
        return [self.frontViewController shouldAutorotate]
            && [self.leftViewController shouldAutorotate];
    }
    else if ([self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate]
            && [self.rightViewController shouldAutorotate];
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
        return self.frontViewController.supportedInterfaceOrientations
             & self.leftViewController.supportedInterfaceOrientations
             & self.rightViewController.supportedInterfaceOrientations;
    }
    else if ([self hasLeftViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations
             & self.leftViewController.supportedInterfaceOrientations;
    }
    else if ([self hasRightViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations
             & self.rightViewController.supportedInterfaceOrientations;
    }
    else
    {
        return self.frontViewController.supportedInterfaceOrientations;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.frontViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
        && [self.leftViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
        && [self.rightViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.frontViewContainer refreshShadowWithAnimationDuration:duration];
}

#pragma mark - Memory Management

- (void)dealloc
{
    [self.frontViewController removeFromParentViewController];
    [self.frontViewController.view removeFromSuperview];
    self.frontViewContainer = nil;
    
    [self.leftViewController removeFromParentViewController];
    [self.leftViewController.view removeFromSuperview];
    self.leftViewContainer = nil;
        
    [self.rightViewController removeFromParentViewController];
    [self.rightViewController.view removeFromSuperview];
    self.rightViewContainer = nil;
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

NS_INLINE BOOL isZero(CGFloat value)
{
    return (value == 0.0f);
}

NS_INLINE void safelyExecuteCompletionBlock(PKDefaultCompletionHandler block)
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        (block != NULL) ? block() : nil;
    });
}

NS_INLINE void safelyExecuteErrorBlock(PKDefaultErrorHandler block, NSError *error)
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        (block != NULL) ? block(error) : nil;
    });
}

@end
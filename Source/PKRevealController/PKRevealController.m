/*
    PKRevealController > PKRevealController.m
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

#import "PKRevealController.h"
#import "NSObject+PKBlocks.h"
#import "PKLayerAnimator.h"
#import "PKRevealControllerView.h"
#import "PKLog.h"

#define DEFAULT_ANIMATION_DURATION_VALUE 0.185
#define DEFAULT_ANIMATION_CURVE_VALUE UIViewAnimationCurveLinear
#define DEFAULT_LEFT_VIEW_WIDTH_RANGE NSMakeRange(260, 40)
#define DEFAULT_RIGHT_VIEW_WIDTH_RANGE DEFAULT_LEFT_VIEW_WIDTH_RANGE
#define DEFAULT_ALLOWS_OVERDRAW_VALUE YES
#define DEFAULT_ANIMATION_TYPE_VALUE PKRevealControllerAnimationTypeStatic
#define DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE 800.0f
#define DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE YES
#define DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE YES
#define DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE YES
#define DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_IN_PRESENTATION_MODE_VALUE YES

NSString * const PKRevealControllerAnimationDurationKey = @"animationDuration";
NSString * const PKRevealControllerAnimationCurveKey = @"animationCurve";
NSString * const PKRevealControllerAnimationTypeKey = @"animationType";
NSString * const PKRevealControllerAllowsOverdrawKey = @"allowsOverdraw";
NSString * const PKRevealControllerQuickSwipeToggleVelocityKey = @"quickSwipeVelocity";
NSString * const PKRevealControllerDisablesFrontViewInteractionKey = @"disablesFrontViewInteraction";
NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey = @"recognizesPanningOnFrontView";
NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey = @"recognizesResetTapOnFrontView";
NSString * const PKRevealControllerRecognizesResetTapOnFrontViewInPresentationModeKey = @"recognizesResetTapOnFrontViewInPresentationMode";

static NSString *kPKRevealControllerFrontViewTranslationAnimationKey = @"frontViewTranslation";

typedef struct
{
    CGPoint initialTouchPoint;
    CGPoint previousTouchPoint;
    CGPoint currentTouchPoint;
} UIGestureRecognizerInteractionFlags;

typedef struct
{
    UIGestureRecognizerInteractionFlags recognizerFlags;
    CGPoint initialFrontViewPosition;
    BOOL isInteracting;
} PKRevealControllerFrontViewInteractionFlags;

@interface PKRevealController()
{
    PKRevealControllerFrontViewInteractionFlags _frontViewInteraction;
}

#pragma mark - Properties
@property (nonatomic, strong, readwrite) PKRevealControllerView *frontView;
@property (nonatomic, strong, readwrite) PKRevealControllerView *leftView;
@property (nonatomic, strong, readwrite) PKRevealControllerView *rightView;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readwrite) PKRevealControllerState state;

@property (nonatomic, assign, readwrite) NSRange leftViewWidthRange;
@property (nonatomic, assign, readwrite) NSRange rightViewWidthRange;

@property (nonatomic, strong, readwrite) PKLayerAnimator *animator;

#pragma mark - Methods
- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options;

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                                    options:(NSDictionary *)options;

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options;

@end

@implementation PKRevealController

#pragma mark - Initialization

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                         rightViewController:rightViewController
                                                     options:nil];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                                     options:nil];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                         rightViewController:rightViewController
                                                     options:nil];
}

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                                    options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:leftViewController
                         rightViewController:nil
                                     options:options];
}

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:nil
                         rightViewController:rightViewController
                                     options:options];
}

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                         leftViewController:(UIViewController *)leftViewController
                        rightViewController:(UIViewController *)rightViewController
                                    options:(NSDictionary *)options
{
    self = [self init];
    
    if (self)
    {
        _frontViewController = frontViewController;
        _leftViewController = leftViewController;
        _rightViewController = rightViewController;
        
        _frontViewController.revealController = self;
        _leftViewController.revealController = self;
        _rightViewController.revealController = self;
        
        [self setValuesForKeysWithDictionary:options];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self loadDefaultValues];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self loadDefaultValues];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self)
    {
        [self loadDefaultValues];
    }
    
    return self;
}
#pragma mark - Deprecated Initialization

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

#pragma mark - Actions

- (void)showLeftViewController
{
    [self showViewController:self.leftViewController];
}

- (void)showRightViewController
{
    [self showViewController:self.rightViewController];
}

- (void)showFrontViewController
{
    [self showViewController:self.frontViewController];
}

- (void)showViewController:(UIViewController *)controller
{
    [self showViewController:controller animated:YES completion:nil];
}

- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion
{
    PKRevealControllerState toState = PKRevealControllerShowsFrontViewController;
    CGPoint toPoint = [self centerPointForState:toState];
    
    if ([controller isEqual:self.leftViewController])
    {
        toState = PKRevealControllerShowsLeftViewController;
        toPoint = [self centerPointForState:toState];
    }
    else if ([controller isEqual:self.rightViewController])
    {
        toState = PKRevealControllerShowsRightViewController;
        toPoint = [self centerPointForState:toState];
    }
    
    if (animated)
    {
        [self animateToState:toState completion:completion];
    }
    else
    {
        self.frontView.layer.position = toPoint;
    }
}

- (void)enterPresentationModeForViewController:(UIViewController *)controller
                                      animated:(BOOL)animated
                                    completion:(PKDefaultCompletionHandler)completion
{
    if (![controller isEqual:self.rightViewController]  ||
        ![controller isEqual:self.leftViewController])
    {
        return;
    }
    
    PKRevealControllerState toState = PKRevealControllerShowsLeftViewControllerInPresentationMode;
    
    if ([controller isEqual:self.rightViewController])
    {
        toState = PKRevealControllerShowsRightViewControllerInPresentationMode;
    }
    
    [self animateToState:toState completion:completion];
}

- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion
{
    NSAssert([self hasLeftViewController] || [self hasRightViewController], @"%@ ERROR - %s : Cannot enter presentation mode without either left or right view controller.", [self class], __PRETTY_FUNCTION__);
    
    PKRevealControllerState toState = self.state;
    
    if ([self hasLeftViewController] && [self hasRightViewController])
    {
        if (self.state == PKRevealControllerShowsLeftViewController)
        {
            toState = PKRevealControllerShowsLeftViewControllerInPresentationMode;
        }
        else if (self.state == PKRevealControllerShowsRightViewController)
        {
            toState = PKRevealControllerShowsRightViewControllerInPresentationMode;
        }
        else
        {
            PKLog(@"%@ ERROR - %s : Cannot implicitly determine which side to enter presentation mode for. Please use enterPresentationModeForController:animated:completion: method.", [self class], __PRETTY_FUNCTION__);
            
            [self pk_performBlock:^
            {
                if (completion)
                {
                    completion(NO);
                }
            } onMainThread:YES];
            
            return;
        }
    }
    else if ([self hasLeftViewController])
    {
        toState = PKRevealControllerShowsLeftViewControllerInPresentationMode;
    }
    else if ([self hasRightViewController])
    {
        toState = PKRevealControllerShowsRightViewControllerInPresentationMode;
    }
    
    [self animateToState:toState completion:completion];
}

- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    PKRevealControllerState toState = PKRevealControllerShowsFrontViewController;
    
    if (!entirely)
    {
        if (self.state == PKRevealControllerShowsLeftViewControllerInPresentationMode)
        {
            toState = PKRevealControllerShowsLeftViewController;
        }
        else if (self.state == PKRevealControllerShowsRightViewControllerInPresentationMode)
        {
            toState = PKRevealControllerShowsRightViewController;
        }
    }
    
    [self animateToState:toState completion:completion];
}

- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion
{
    [self setFrontViewController:frontViewController];
    
    if (focus)
    {
        [self showViewController:self.frontViewController
                        animated:YES
                      completion:completion];
    }
    else
    {
        [self pk_performBlock:^
        {
            if (completion)
            {
                completion(NO);
            }
        } onMainThread:YES];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
    if (frontViewController != _frontViewController)
    {
        if (_frontViewController)
        {
            [self removeViewController:_frontViewController];
        }
        
        _frontViewController = frontViewController;
        
        if (_frontViewController)
        {
            [self addViewController:_frontViewController container:self.frontView];
        }
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (leftViewController != _leftViewController)
    {
        if (_leftViewController)
        {
            [self removeViewController:_leftViewController];
        }
        
        _leftViewController = leftViewController;
        
        if (_leftViewController)
        {
            [self addViewController:_leftViewController container:self.leftView];
        }
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    if (rightViewController != _rightViewController)
    {
        if (_rightViewController)
        {
            [self removeViewController:_rightViewController];
        }
        
        _rightViewController = rightViewController;
        
        if (_rightViewController)
        {
            [self addViewController:_rightViewController container:self.rightView];
        }
    }
}

- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller
{
    if ([controller isEqual:self.leftViewController])
    {
        self.leftViewWidthRange = NSMakeRange(minWidth, (maxWidth - minWidth));
    }
    else if ([controller isEqual:self.rightViewController])
    {
        self.rightViewWidthRange = NSMakeRange(minWidth, (maxWidth - minWidth));
    }
}

- (void)setOptions:(NSDictionary *)options
{
    if (options)
    {
        [self setValuesForKeysWithDictionary:options];
    }
}

- (NSDictionary *)options
{
    NSArray *keys = @[PKRevealControllerAnimationDurationKey,
                      PKRevealControllerAnimationCurveKey,
                      PKRevealControllerAnimationTypeKey,
                      PKRevealControllerAllowsOverdrawKey,
                      PKRevealControllerQuickSwipeToggleVelocityKey,
                      PKRevealControllerDisablesFrontViewInteractionKey,
                      PKRevealControllerRecognizesPanningOnFrontViewKey,
                      PKRevealControllerRecognizesResetTapOnFrontViewKey,
                      PKRevealControllerRecognizesResetTapOnFrontViewInPresentationModeKey];
    
    return [self dictionaryWithValuesForKeys:keys];

}

- (UIViewController *)focusedController
{
    UIViewController *controller = nil;
    
    switch (self.state)
    {
        case PKRevealControllerShowsFrontViewController:
            controller = self.frontViewController;
            break;
            
        case PKRevealControllerShowsLeftViewController:
        case PKRevealControllerShowsLeftViewControllerInPresentationMode:
            controller = self.leftViewController;
            break;
            
        case PKRevealControllerShowsRightViewController:
        case PKRevealControllerShowsRightViewControllerInPresentationMode:
            controller = self.rightViewController;
            break;
            
        default:
            break;
    }
    
    return controller;
}

- (BOOL)isPresentationModeActive
{
    return (self.state == PKRevealControllerShowsLeftViewControllerInPresentationMode ||
            self.state == PKRevealControllerShowsRightViewControllerInPresentationMode);
}

- (BOOL)hasRightViewController
{
    return (self.rightViewController != nil);
}

- (BOOL)hasLeftViewController
{
    return (self.leftViewController != nil);
}

- (void)loadDefaultValues
{
    _animationDuration = DEFAULT_ANIMATION_DURATION_VALUE;
    _animationCurve = DEFAULT_ANIMATION_CURVE_VALUE;
    _animationType = DEFAULT_ANIMATION_TYPE_VALUE;
    _quickSwipeVelocity = DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE;
    _allowsOverdraw = DEFAULT_ALLOWS_OVERDRAW_VALUE;
    _disablesFrontViewInteraction = DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE;
    _recognizesPanningOnFrontView = DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE;
    _recognizesResetTapOnFrontView = DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE;
    _leftViewWidthRange = DEFAULT_LEFT_VIEW_WIDTH_RANGE;
    _rightViewWidthRange = DEFAULT_RIGHT_VIEW_WIDTH_RANGE;
    _recognizesResetTapOnFrontViewInPresentationMode = DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_IN_PRESENTATION_MODE_VALUE;
}

- (void)setupContainerViews
{
    self.rightView = [[PKRevealControllerView alloc] initWithFrame:self.view.bounds];
    self.leftView = [[PKRevealControllerView alloc] initWithFrame:self.view.bounds];
    self.frontView = [[PKRevealControllerView alloc] initWithFrame:self.view.bounds];
    
    self.rightView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.leftView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.frontView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.rightView.viewController = self.rightViewController;
    self.leftView.viewController = self.leftViewController;
    self.frontView.viewController = self.frontViewController;
    
    self.frontView.shadow = YES;
    
    self.leftView.hidden = YES;
    self.rightView.hidden = YES;
    
    [self.view addSubview:self.rightView];
    [self.view addSubview:self.leftView];
    [self.view addSubview:self.frontView];
    
    [self addViewController:self.frontViewController container:self.frontView];
}

- (void)setupGestureRecognizers
{
    self.revealPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(didRecognizePanGesture:)];
    
    self.revealPanGestureRecognizer.maximumNumberOfTouches = 1;
    
    self.revealResetTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(didRecognizeTapGesture:)];
    
    [self updatePanGestureRecognizerPresence];
    [self updateTapGestureRecognizerPrecence];
}

- (void)setRecognizesResetTapOnFrontView:(BOOL)recognizesResetTapOnFrontView
{
    if (_recognizesResetTapOnFrontView != recognizesResetTapOnFrontView)
    {
        _recognizesResetTapOnFrontView = recognizesResetTapOnFrontView;
        [self updateTapGestureRecognizerPrecence];
    }
}

- (void)setRecognizesPanningOnFrontView:(BOOL)recognizesPanningOnFrontView
{
    if (_recognizesPanningOnFrontView != recognizesPanningOnFrontView)
    {
        _recognizesPanningOnFrontView = recognizesPanningOnFrontView;
        [self updatePanGestureRecognizerPresence];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _state = PKRevealControllerShowsFrontViewController;
    
    [self setupContainerViews];
    [self setupGestureRecognizers];
    
    self.animator = [PKLayerAnimator animatorForLayer:self.frontView.layer];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController *controller = nil;
    
    switch (self.state)
    {
        case PKRevealControllerShowsLeftViewControllerInPresentationMode:
        case PKRevealControllerShowsLeftViewController:
            controller = self.leftViewController;
            break;
        case PKRevealControllerShowsRightViewControllerInPresentationMode:
        case PKRevealControllerShowsRightViewController:
            controller = self.rightViewController;
            break;
        case PKRevealControllerShowsFrontViewController:
            controller = self.frontViewController;
            break;
            
        default:
        {
            // Fail quitely.
        }
            break;
    }
    
    if ([controller respondsToSelector:@selector(preferredStatusBarStyle)])
    {
        return [controller preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleDefault;
}

#endif

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"state"])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Gesture Recognition

- (void)didRecognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.state != PKRevealControllerShowsFrontViewController)
    {
        [self animateToState:PKRevealControllerShowsFrontViewController completion:nil];
    }
}

- (void)didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self handlePanGestureBeganWithRecognizer:recognizer];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self handlePanGestureChangedWithRecognizer:recognizer];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self handlePanGestureEndedWithRecognizer:recognizer];
        }
            break;
            
        default:
            [self handlePanGestureEndedWithRecognizer:recognizer];
            break;
    }
}

#pragma mark Gesture Handling

- (void)handlePanGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    [self.animator stopAnimationForKey:kPKRevealControllerFrontViewTranslationAnimationKey];
    
    _frontViewInteraction.recognizerFlags.initialTouchPoint = [recognizer translationInView:self.frontView];
    _frontViewInteraction.recognizerFlags.previousTouchPoint = _frontViewInteraction.recognizerFlags.initialTouchPoint;
    _frontViewInteraction.initialFrontViewPosition = self.frontView.layer.position;
    _frontViewInteraction.isInteracting = YES;
    
    [self updateRearViewVisibility];
}

- (void)handlePanGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    _frontViewInteraction.recognizerFlags.currentTouchPoint = [recognizer translationInView:self.frontView];
    CGFloat newX = _frontViewInteraction.initialFrontViewPosition.x + (_frontViewInteraction.recognizerFlags.initialTouchPoint.x + _frontViewInteraction.recognizerFlags.currentTouchPoint.x);
    
    if (![self hasLeftViewController] && newX >= [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        newX = [self centerPointForState:PKRevealControllerShowsFrontViewController].x;
    }
    else if (![self hasRightViewController] && newX <= [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        newX = [self centerPointForState:PKRevealControllerShowsFrontViewController].x;
    }
    else
    {
        CGFloat dampenedLeft = [self dampenedValueForRealValue:(newX - CGRectGetMidX(self.frontView.bounds)) inRange:self.leftViewWidthRange] + CGRectGetMidX(self.frontView.bounds);
        CGFloat dampenedRight = [self dampenedValueForRealValue:(newX - CGRectGetMidX(self.frontView.bounds)) inRange:self.rightViewWidthRange] + CGRectGetMidX(self.frontView.bounds);
        
        if (newX >= [self centerPointForState:PKRevealControllerShowsLeftViewControllerInPresentationMode].x &&
            !([self centerPointForState:PKRevealControllerShowsLeftViewControllerInPresentationMode].x >= dampenedLeft))
        {
            newX = self.frontView.layer.position.x;
        }
        else if (newX <= [self centerPointForState:PKRevealControllerShowsRightViewControllerInPresentationMode].x &&
                 !([self centerPointForState:PKRevealControllerShowsRightViewControllerInPresentationMode].x <= dampenedRight))
        {
            newX = self.frontView.layer.position.x;
        }
        else if (newX >= [self centerPointForState:PKRevealControllerShowsLeftViewController].x)
        {
            newX = dampenedLeft;
        }
        else if (newX <= [self centerPointForState:PKRevealControllerShowsRightViewController].x)
        {
            newX = dampenedRight;
        }
    }
    
    self.frontView.layer.position = CGPointMake(newX, self.frontView.layer.position.y);
    [self updateRearViewVisibility];
    
    _frontViewInteraction.recognizerFlags.previousTouchPoint = _frontViewInteraction.recognizerFlags.currentTouchPoint;
}

- (void)handlePanGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    _frontViewInteraction.recognizerFlags.initialTouchPoint = CGPointZero;
    _frontViewInteraction.recognizerFlags.previousTouchPoint = CGPointZero;
    _frontViewInteraction.recognizerFlags.currentTouchPoint = CGPointZero;
    _frontViewInteraction.initialFrontViewPosition = CGPointZero;
    _frontViewInteraction.isInteracting = NO;
    
    if ([self shouldMoveFrontViewLeftwardsForVelocity:[recognizer velocityInView:self.view].x])
    {
        PKRevealControllerState toState = PKRevealControllerShowsFrontViewController;
        
        if (self.state == PKRevealControllerShowsRightViewController ||
            self.state == PKRevealControllerShowsRightViewControllerInPresentationMode)
        {
            toState = self.state;
        }
        else if (self.state == PKRevealControllerShowsFrontViewController && [self hasRightViewController])
        {
            toState = PKRevealControllerShowsRightViewController;
        }
        
        [self animateToState:toState completion:nil];
    }
    else if ([self shouldMoveFrontViewRightwardsForVelocity:[recognizer velocityInView:self.frontView].x])
    {
        PKRevealControllerState toState = PKRevealControllerShowsFrontViewController;
        
        if (self.state == PKRevealControllerShowsFrontViewController && [self hasLeftViewController])
        {
            toState = PKRevealControllerShowsLeftViewController;
        }
        else if (self.state == PKRevealControllerShowsLeftViewController ||
                 self.state == PKRevealControllerShowsLeftViewControllerInPresentationMode)
        {
            toState = self.state;
        }
        
        [self animateToState:toState completion:nil];
    }
    else
    {
        [self snapFrontViewToAppropriateEdge];
    }
}

#pragma mark - Math

- (CGFloat)dampenedValueForRealValue:(CGFloat)realValue inRange:(NSRange)absoluteRange
{
    BOOL isNegative = (realValue < 0);
    
    realValue = fabs(realValue);
    
    // PKLog(@"Range: [%u, %u], Real Value: %f", absoluteRange.location, (absoluteRange.location + absoluteRange.length), realValue);
    
    NSRange unitRange = NSMakeRange(0.0, 1.0);
    
    CGFloat (^LinearMap)(CGFloat x, NSRange from, NSRange to) = ^(CGFloat x, NSRange from, NSRange to)
    {
        // [a1, b1] -> [a2, b2]
        CGFloat a1 = from.location;
        CGFloat b1 = from.location + from.length;
        
        CGFloat a2 = to.location;
        CGFloat b2 = to.location + to.length;
        
        return ((x - a1) * (b2 - a2) / (b1 - a1)) + a2;
    };
    
    CGFloat unitValue = LinearMap(realValue, absoluteRange, unitRange);
    
    // PKLog(@"Mapped (To Unit): %f -> %f", realValue, unitValue);
    
    CGFloat (^UnitDampening)(CGFloat x) = ^(CGFloat x)
    {
        // Dampening Function.
        return (CGFloat)((2.5 / M_PI) * atanf(x));
    };
    
    CGFloat dampenedUnitValue = UnitDampening(unitValue);
    
    // PKLog(@"Dampened: %f -> %f", unitValue, dampenedUnitValue);
    
    CGFloat result = LinearMap(dampenedUnitValue, unitRange, absoluteRange);
    
    if (isNegative)
    {
        result = -result;
    }
    
    return result;
}

#pragma mark - Internal

- (void)setState:(PKRevealControllerState)state
{
    if (state != _state)
    {
        [self willChangeValueForKey:@"state"];
        
        if (self.delegate &&
            [self.delegate conformsToProtocol:@protocol(PKRevealing)] &&
            [self.delegate respondsToSelector:@selector(revealController:willChangeToState:)])
        {
            [self.delegate revealController:self willChangeToState:state];
        }
        
        _state = state;
        
        [self didChangeValueForKey:@"state"];
        
        if (self.delegate &&
            [self.delegate conformsToProtocol:@protocol(PKRevealing)] &&
            [self.delegate respondsToSelector:@selector(revealController:didChangeToState:)])
        {
            [self.delegate revealController:self didChangeToState:state];
        }
    }
}

- (void)updateRearViewVisibilityForFrontViewPosition:(CGPoint)position
{
    if (position.x > [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        [self showLeftView];
    }
    else if (position.x < [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        [self showRightView];
    }
    else
    {
        [self hideRearViews];
    }
    
    self.state = [self stateForCurrentFrontViewPosition];
}

- (void)updateRearViewVisibility
{
    if ([self isLeftViewVisible])
    {
        if (self.leftView.hidden)
        {
            [self showLeftView];
        }
    }
    else if ([self isRightViewVisible])
    {
        if (self.rightView.hidden)
        {
            [self showRightView];
        }
    }
    else
    {
        if (!self.leftView.hidden || !self.rightView.hidden)
        {
            [self hideRearViews];
        }
    }
    
    self.state = [self stateForCurrentFrontViewPosition];
}

- (void)updateTapGestureRecognizerPrecence
{
    if ((self.state == PKRevealControllerShowsRightViewControllerInPresentationMode ||
        self.state == PKRevealControllerShowsLeftViewControllerInPresentationMode) &&
        self.recognizesResetTapOnFrontViewInPresentationMode)
    {
        if(![self.frontView.gestureRecognizers containsObject:self.revealResetTapGestureRecognizer])
        {
            [self.frontView addGestureRecognizer:self.revealResetTapGestureRecognizer];
        }
    }
    else if ((self.state == PKRevealControllerShowsLeftViewController ||
              self.state == PKRevealControllerShowsRightViewController) &&
             self.recognizesResetTapOnFrontView)
    {
        if(![self.frontView.gestureRecognizers containsObject:self.revealResetTapGestureRecognizer])
        {
            [self.frontView addGestureRecognizer:self.revealResetTapGestureRecognizer];
        }
    }
    else
    {
        if ([self.frontView.gestureRecognizers containsObject:self.revealResetTapGestureRecognizer])
        {
            [self.frontView removeGestureRecognizer:self.revealResetTapGestureRecognizer];
        }
    }
}

- (void)updatePanGestureRecognizerPresence
{
    if (self.recognizesPanningOnFrontView)
    {
        if (![self.frontView.gestureRecognizers containsObject:self.revealPanGestureRecognizer])
        {
            [self.frontView addGestureRecognizer:self.revealPanGestureRecognizer];
        }
    }
    else
    {
        if ([self.frontView.gestureRecognizers containsObject:self.revealPanGestureRecognizer])
        {
            [self.frontView removeGestureRecognizer:self.revealPanGestureRecognizer];
        }
    }
}

- (void)hideRearViews
{
    self.rightView.hidden = YES;
    self.leftView.hidden = YES;
    [self removeViewController:self.leftViewController];
    [self removeViewController:self.rightViewController];
    [self.frontView setUserInteractionForContainedViewEnabled:YES];
}

- (void)showRightView
{
    self.rightView.hidden = NO;
    self.leftView.hidden = YES;
    [self removeViewController:self.leftViewController];
    [self addViewController:self.rightViewController container:self.rightView];
    [self.frontView setUserInteractionForContainedViewEnabled:NO];
}

- (void)showLeftView
{
    self.rightView.hidden = YES;
    self.leftView.hidden = NO;
    [self removeViewController:self.rightViewController];
    [self addViewController:self.leftViewController container:self.leftView];
    [self.frontView setUserInteractionForContainedViewEnabled:NO];
}

- (BOOL)isLeftViewVisible
{
    CALayer *layer = (CALayer *)[self.frontView.layer presentationLayer];
    return (layer.position.x > CGRectGetMidX(self.view.bounds));
}

- (BOOL)isRightViewVisible
{
    CALayer *layer = (CALayer *)[self.frontView.layer presentationLayer];
    return (layer.position.x < CGRectGetMidX(self.view.bounds));
}

- (void)snapFrontViewToAppropriateEdge
{
    CGFloat visibleWidth = 0.0;
    
    PKRevealControllerState toState = PKRevealControllerShowsFrontViewController;
    
    if ([self isLeftViewVisible])
    {
        visibleWidth = self.frontView.layer.position.x - self.leftView.layer.position.x;
        
        if (visibleWidth > ([self leftViewMinWidth] / 2.0))
        {
            toState = PKRevealControllerShowsLeftViewController;
        }
    }
    else if ([self isRightViewVisible])
    {
        visibleWidth = self.rightView.layer.position.x - self.frontView.layer.position.x;
        
        if (visibleWidth > ([self rightViewMinWidth] / 2.0))
        {
            toState = PKRevealControllerShowsRightViewController;
        }
    }
    
    [self animateToState:toState completion:nil];
}

- (BOOL)shouldMoveFrontViewRightwardsForVelocity:(CGFloat)velocity
{
    return (velocity > 0 && velocity > self.quickSwipeVelocity);
}

- (BOOL)shouldMoveFrontViewLeftwardsForVelocity:(CGFloat)velocity
{
    return (velocity < 0 && fabs(velocity) > self.quickSwipeVelocity);
}

#pragma mark - View Controller Containment

- (void)addViewController:(UIViewController *)childController container:(UIView *)container
{
    if (childController &&
        ![self.childViewControllers containsObject:childController])
    {
        [self addChildViewController:childController];
        childController.view.frame = container.bounds;
        childController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        childController.revealController = self;
        [container addSubview:childController.view];
		if ([container isKindOfClass:[PKRevealControllerView class]]) {
			((PKRevealControllerView *)container).viewController = childController;
		}
        [childController didMoveToParentViewController:self];
    }
}

- (void)removeViewController:(UIViewController *)childController
{
    if (childController && [self.childViewControllers containsObject:childController])
    {
        [childController willMoveToParentViewController:nil];
        [childController.view removeFromSuperview];
        [childController removeFromParentViewController];
        childController.revealController = nil;
    }
}

#pragma mark - Animations

- (void)animateToState:(PKRevealControllerState)toState completion:(PKDefaultCompletionHandler)completion
{
    [self updateRearViewVisibility];
    [self.animator stopAnimationForKey:kPKRevealControllerFrontViewTranslationAnimationKey];
    
    PKSequentialAnimation *animation = [PKSequentialAnimation animationForKeyPath:@"position"
                                                                           values:[self keyPositionsToState:toState]
                                                                         duration:self.animationDuration];
    
    __weak PKRevealController *weakSelf = self;
    animation.progressHandler = ^(NSValue *fromValue, NSValue *toValue, NSUInteger index)
    {
        if ([fromValue CGPointValue].x == [weakSelf centerPointForState:PKRevealControllerShowsFrontViewController].x)
        {
            [weakSelf updateRearViewVisibilityForFrontViewPosition:[toValue CGPointValue]];
        }
        else
        {
            [weakSelf updateRearViewVisibility];
        }
    };
    
    animation.completionHandler = ^(BOOL finished)
    {
        if (finished)
        {
            [weakSelf updateRearViewVisibility];
        }
        
        [weakSelf updateTapGestureRecognizerPrecence];
        [weakSelf updatePanGestureRecognizerPresence];
        
        [weakSelf pk_performBlock:^
        {
            if (completion)
            {
                completion(finished);
            }
        } onMainThread:YES];
    };
    
    [self.animator addSequentialAnimation:animation forKey:kPKRevealControllerFrontViewTranslationAnimationKey];
    [self.animator startAnimationForKey:kPKRevealControllerFrontViewTranslationAnimationKey];
}

#pragma mark Helper

- (NSArray *)keyPositionsToState:(PKRevealControllerState)toState
{
    NSArray *keyPositions = nil;
    PKRevealControllerState fromState = self.state;
    
    if (fromState == toState)
    {
        keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
    }
    else
    {
        if (fromState == PKRevealControllerShowsLeftViewControllerInPresentationMode)
        {
            if (toState == PKRevealControllerShowsLeftViewController ||
                toState == PKRevealControllerShowsFrontViewController)
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
            }
            else
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:YES];
            }
        }
        else if (fromState == PKRevealControllerShowsLeftViewController)
        {
            if (toState == PKRevealControllerShowsLeftViewControllerInPresentationMode ||
                toState == PKRevealControllerShowsFrontViewController)
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
            }
            else
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:YES];
            }
        }
        else if (fromState == PKRevealControllerShowsFrontViewController)
        {
            keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
        }
        else if (fromState == PKRevealControllerShowsRightViewController)
        {
            if (toState == PKRevealControllerShowsFrontViewController ||
                toState == PKRevealControllerShowsRightViewControllerInPresentationMode)
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
            }
            else
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:YES];
            }
        }
        else if (fromState == PKRevealControllerShowsRightViewControllerInPresentationMode)
        {
            if (toState == PKRevealControllerShowsRightViewController ||
                toState == PKRevealControllerShowsFrontViewController)
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:NO];
            }
            else
            {
                keyPositions = [self keyPositionsToState:toState viaFrontView:YES];
            }
        }
    }
    
    return keyPositions;
}

- (NSArray *)keyPositionsToState:(PKRevealControllerState)toState
                    viaFrontView:(BOOL)viaFrontView
{
    if (viaFrontView)
    {
        return @[[NSValue valueWithCGPoint:[self centerPointForState:PKRevealControllerShowsFrontViewController]],
                 [NSValue valueWithCGPoint:[self centerPointForState:toState]]];
    }
    else
    {
        return @[[NSValue valueWithCGPoint:[self centerPointForState:toState]]];
    }
}

- (PKRevealControllerState)stateForCurrentFrontViewPosition
{
    CGFloat x = self.frontView.layer.position.x;
    
    if (x <= [self centerPointForState:PKRevealControllerShowsRightViewControllerInPresentationMode].x)
    {
        return PKRevealControllerShowsRightViewControllerInPresentationMode;
    }
    else if (x < [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        return PKRevealControllerShowsRightViewController;
    }
    else if (x == [self centerPointForState:PKRevealControllerShowsFrontViewController].x)
    {
        return PKRevealControllerShowsFrontViewController;
    }
    else if (x < [self centerPointForState:PKRevealControllerShowsLeftViewControllerInPresentationMode].x)
    {
        return PKRevealControllerShowsLeftViewController;
    }
    else
    {
        return PKRevealControllerShowsLeftViewControllerInPresentationMode;
    }
}

- (PKRevealControllerType)type
{
    if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return PKRevealControllerTypeBoth;
    }
    else if ([self hasLeftViewController])
    {
        return PKRevealControllerTypeLeft;
    }
    else if ([self hasRightViewController])
    {
        return PKRevealControllerTypeRight;
    }
    else
    {
        return PKRevealControllerTypeNone;
    }
}

#pragma mark - Positioning & Sizing

- (CGPoint)centerPointForState:(PKRevealControllerState)state
{
    CGPoint center = CGPointMake(self.frontView.layer.position.x, self.frontView.layer.position.y);
    
    switch (state)
    {
        case PKRevealControllerShowsFrontViewController:
        {
            center.x = CGRectGetMidX(self.view.bounds);
        }
            break;
            
        case PKRevealControllerShowsLeftViewController:
        {
            center.x = CGRectGetMidX(self.view.bounds) + [self leftViewMinWidth];
        }
            break;
            
        case PKRevealControllerShowsRightViewController:
        {
            center.x = CGRectGetMidX(self.view.bounds) - [self rightViewMinWidth];
        }
            break;
            
        case PKRevealControllerShowsLeftViewControllerInPresentationMode:
        {
            center.x = CGRectGetMidX(self.view.bounds) + [self leftViewMaxWidth];
        }
            break;
            
        case PKRevealControllerShowsRightViewControllerInPresentationMode:
        {
            center.x = CGRectGetMidX(self.view.bounds) - [self rightViewMaxWidth];
        }
    }
    
    return center;
}

- (CGFloat)leftViewMinWidth
{
    return self.leftViewWidthRange.location;
}

- (CGFloat)rightViewMinWidth
{
    return self.rightViewWidthRange.location;
}

- (CGFloat)leftViewMaxWidth
{
    return self.leftViewWidthRange.location + self.leftViewWidthRange.length;
}

- (CGFloat)rightViewMaxWidth
{
    return self.rightViewWidthRange.location + self.rightViewWidthRange.length;
}

#pragma mark - Autorotation

/*
 * Please Note:
 * The PKRevealController will only rotate if, and only if, all the controllers support the desired orientation.
 */
- (BOOL)shouldAutorotate
{
    if (_frontViewInteraction.isInteracting)
    {
        return NO;
    }
    else if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate] &&
               [self.leftViewController shouldAutorotate] &&
               [self.rightViewController shouldAutorotate];
    }
    else if ([self hasLeftViewController])
    {
        return [self.frontViewController shouldAutorotate] &&
               [self.leftViewController shouldAutorotate];
    }
    else if ([self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotate] &&
               [self.rightViewController shouldAutorotate];
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
        return self.frontViewController.supportedInterfaceOrientations &
               self.leftViewController.supportedInterfaceOrientations &
               self.rightViewController.supportedInterfaceOrientations;
    }
    else if ([self hasLeftViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations &
               self.leftViewController.supportedInterfaceOrientations;
    }
    else if ([self hasRightViewController])
    {
        return self.frontViewController.supportedInterfaceOrientations &
               self.rightViewController.supportedInterfaceOrientations;
    }
    else
    {
        return self.frontViewController.supportedInterfaceOrientations;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_frontViewInteraction.isInteracting)
    {
        return NO;
    }
    else if ([self hasLeftViewController] && [self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
               [self.leftViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
               [self.rightViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    else if ([self hasLeftViewController])
    {
        return [self.frontViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
               [self.leftViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    else if ([self hasRightViewController])
    {
        return [self.frontViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
               [self.rightViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    else
    {
        return [self.frontViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self.frontView updateShadowWithAnimationDuration:duration];
}

@end

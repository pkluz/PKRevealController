/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKRevealController.h"
#import "PKRevealControllerContainerView.h"

#define DEFAULT_ANIMATION_DURATION_VALUE 0.185
#define DEFAULT_ANIMATION_CURVE_VALUE UIViewAnimationCurveLinear
#define DEFAULT_LEFT_VIEW_WIDTH_RANGE NSMakeRange(280, 310)
#define DEFAULT_RIGHT_VIEW_WIDTH_RANGE DEFAULT_LEFT_VIEW_WIDTH_RANGE
#define DEFAULT_ALLOWS_OVERDRAW_VALUE YES
#define DEFAULT_ANIMATION_TYPE_VALUE PKRevealControllerAnimationTypeStatic
#define DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE 800.0f
#define DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE YES
#define DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE YES
#define DEFAULT_RECOGNIZES_PAN_ON_LEFT_VIEW_VALUE NO
#define DEFAULT_RECOGNIZES_PAN_ON_RIGHT_VIEW_VALUE NO
#define DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE YES

#define DEFAULT_LEFT_VIEW_SLIDE_AMOUNT 0.0f
#define DEFAULT_RIGHT_VIEW_SLIDE_AMOUNT 0.0f

@interface PKRevealControllerAnimationDelegateWrapper : NSObject

@property (nonatomic, weak) NSObject<PKRevealControllerAnimationDelegate> *delegate;

@end

@implementation PKRevealControllerAnimationDelegateWrapper

-(BOOL)isEqual:(id)object
{
    if (object == nil || ![object isKindOfClass:self.class]) {
        return NO;
    } else {
        return ([self delegate] == [(PKRevealControllerAnimationDelegateWrapper *)object delegate]);
    }
}

@end

@interface PKRevealController () <PKRevealControllerContainerViewDelegate>

#pragma mark - Properties
@property (nonatomic, assign, readwrite) PKRevealControllerState state;
@property (nonatomic, assign, readwrite) BOOL isPresentationModeActive;

@property (nonatomic, strong, readwrite) UIViewController *frontViewController;
@property (nonatomic, strong, readwrite) UIViewController *leftViewController;
@property (nonatomic, strong, readwrite) UIViewController *rightViewController;

@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *frontViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *leftViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *rightViewContainer;

@property (nonatomic, assign, readwrite) NSRange leftViewWidthRange;
@property (nonatomic, assign, readwrite) NSRange rightViewWidthRange;

@property (nonatomic, strong, readwrite) NSMutableDictionary *controllerOptions;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealFrontPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealLeftPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealRightPanGestureRecognizer;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readwrite) CGPoint initialTouchLocation;
@property (nonatomic, assign, readwrite) CGPoint previousTouchLocation;

@property (nonatomic, assign) CGFloat animationDelegatePreviousLeftWidth;
@property (nonatomic, assign) CGFloat animationDelegatePreviousRightWidth;
@property (nonatomic, strong) NSMutableArray *animationDelegateWrappers;

- (void)notifyDelegateDidShowViewController:(UIViewController *)controller animated:(BOOL)animated;

@end

@implementation PKRevealController

NSString * const PKRevealControllerDidShowFrontViewControllerNotification = @"PKRevealControllerDidShowFrontViewControllerNotification";
NSString * const PKRevealControllerDidShowLeftViewControllerNotification = @"PKRevealControllerDidShowLeftViewControllerNotification";
NSString * const PKRevealControllerDidShowRightViewControllerNotification = @"PKRevealControllerDidShowRightViewControllerNotification";

NSString * const PKRevealControllerAnimationDurationKey = @"PKRevealControllerAnimationDurationKey";
NSString * const PKRevealControllerAnimationCurveKey = @"PKRevealControllerAnimationCurveKey";
NSString * const PKRevealControllerAnimationTypeKey = @"PKRevealControllerAnimationTypeKey";
NSString * const PKRevealControllerAllowsOverdrawKey = @"PKRevealControllerAllowsOverdrawKey";
NSString * const PKRevealControllerQuickSwipeToggleVelocityKey = @"PKRevealControllerQuickSwipeToggleVelocityKey";
NSString * const PKRevealControllerDisablesFrontViewInteractionKey = @"PKRevealControllerDisablesFrontViewInteractionKey";

NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey = @"PKRevealControllerRecognizesPanningOnFrontViewKey";
NSString * const PKRevealControllerRecognizesPanningOnLeftViewKey = @"PKRevealControllerRecognizesPanningOnLeftViewKey";
NSString * const PKRevealControllerRecognizesPanningOnRightViewKey = @"PKRevealControllerRecognizesPanningOnRightViewKey";

NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey = @"PKRevealControllerRecognizesResetTapOnFrontViewKey";

NSString * const PKRevealControllerLeftViewSlideAmountKey = @"PKRevealControllerLeftViewSlideAmountKey";
NSString * const PKRevealControllerRightViewSlideAmountKey = @"PKRevealControllerRightViewSlideAmountKey";

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
        _frontViewController = frontViewController;
        _rightViewController = rightViewController;
        _leftViewController = leftViewController;
        
        [self commonInitializer];
        
        if (options)
        {
            _controllerOptions = [options mutableCopy];
        }
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
    _controllerOptions = [NSMutableDictionary dictionaryWithCapacity:10];
    _frontViewController.revealController = self;
    _leftViewController.revealController = self;
    _rightViewController.revealController = self;
    
    _leftViewWidthRange = DEFAULT_LEFT_VIEW_WIDTH_RANGE;
    _rightViewWidthRange = DEFAULT_RIGHT_VIEW_WIDTH_RANGE;
}

#pragma mark - Notifications and Delegate

- (void)notifyDelegateDidShowViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(revealController:didShowViewController:animated:)]) {
        [self.delegate revealController:self didShowViewController:controller animated:animated];
    }
    [self postNotificationForViewController:controller alreadyShown:YES];
}

- (void)postNotificationForViewController:(UIViewController *)controller alreadyShown:(BOOL)alreadyShown
{
    NSString *name = nil;
    
    if (controller == self.frontViewController) {
        name = PKRevealControllerDidShowFrontViewControllerNotification;
    } else if (controller == self.leftViewController) {
        name = PKRevealControllerDidShowLeftViewControllerNotification;
    } else if (controller == self.rightViewController) {
        name = PKRevealControllerDidShowRightViewControllerNotification;
    }
    
    if (name != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:controller];
    }
}

#pragma mark - Animation Delegate

- (void)notifyAnimationDelegatesWithLeftChanged:(BOOL)leftChanged rightChanged:(BOOL)rightChanged
{
    if (self.animationDelegateWrappers.count > 0) {
        
        CGFloat leftWidth = self.animationDelegatePreviousLeftWidth;
        CGFloat rightWidth = self.animationDelegatePreviousRightWidth;
        
        NSArray *delegateWrappers = [self.animationDelegateWrappers copy];
        
        for (PKRevealControllerAnimationDelegateWrapper *wrapper in delegateWrappers) {
            if (leftChanged && [wrapper.delegate respondsToSelector:@selector(revealController:didChangeLeftViewControllerVisibleWidth:)]) {
                [wrapper.delegate revealController:self didChangeLeftViewControllerVisibleWidth:leftWidth];
            }
            if (rightChanged && [wrapper.delegate respondsToSelector:@selector(revealController:didChangeRightViewControllerVisibleWidth:)]) {
                [wrapper.delegate revealController:self didChangeRightViewControllerVisibleWidth:rightWidth];
            }
        }
    }
}

- (void)addAnimationDelegate:(NSObject<PKRevealControllerAnimationDelegate> *)delegate
{
    if (delegate != nil) {
        PKRevealControllerAnimationDelegateWrapper *wrapper = [PKRevealControllerAnimationDelegateWrapper new];
        wrapper.delegate = delegate;
        @synchronized(self)
        {
            if (self.animationDelegateWrappers == nil) {
                self.animationDelegateWrappers = [NSMutableArray arrayWithObject:wrapper];
            } else if (![self.animationDelegateWrappers containsObject:wrapper]) {
                [self.animationDelegateWrappers addObject:wrapper];
            }
        }
    }
}

- (void)removeAnimationDelegate:(NSObject<PKRevealControllerAnimationDelegate> *)delegate
{
    if (delegate != nil && self.animationDelegateWrappers.count > 0) {
        
        @synchronized(self)
        {
            NSArray *delegateWrappers = [self.animationDelegateWrappers copy];
            for (PKRevealControllerAnimationDelegateWrapper *wrapper in delegateWrappers) {
                if (wrapper.delegate == delegate || wrapper.delegate == nil) {
                    [self.animationDelegateWrappers removeObject:wrapper];
                }
            }
        }
    }
}

- (void)removeAllAnimationDelegates
{
    @synchronized(self)
    {
        self.animationDelegateWrappers = nil;
    }
}

#pragma mark - PKRevealControllerContainerViewDelegate

-(void)containerView:(PKRevealControllerContainerView *)containerView didChangeFrame:(CGRect)frame
{
    CGRect currentFrame = self.frontViewContainer.frame;
    
    CGFloat leftWidth = MAX(currentFrame.origin.x, 0.0f);
    CGFloat rightWidth = MAX((currentFrame.origin.x * -1.0f), 0.0f);
    
    BOOL leftChanged = (leftWidth != _animationDelegatePreviousLeftWidth);
    BOOL rightChanged = (rightWidth != _animationDelegatePreviousRightWidth);
    
    _animationDelegatePreviousLeftWidth = leftWidth;
    _animationDelegatePreviousRightWidth = rightWidth;
    
    if (leftChanged) {
        CGFloat slideAmount = [self floatPropertyForKey:PKRevealControllerLeftViewSlideAmountKey default:DEFAULT_LEFT_VIEW_SLIDE_AMOUNT];
        slideAmount = MAX(0.0f, MIN(slideAmount, 1.0f));
        CGRect sideFrame = self.leftViewContainer.frame;
        sideFrame.origin.x = slideAmount * (CGRectGetMinX(currentFrame)-sideFrame.size.width);
        self.leftViewContainer.frame = sideFrame;
    }
    
    if (rightChanged) {
        CGFloat slideAmount = [self floatPropertyForKey:PKRevealControllerRightViewSlideAmountKey default:DEFAULT_RIGHT_VIEW_SLIDE_AMOUNT];
        slideAmount = MAX(0.0f, MIN(slideAmount, 1.0f));
        CGRect sideFrame = self.rightViewContainer.frame;
        CGFloat staticOrigin = currentFrame.size.width - sideFrame.size.width;
        sideFrame.origin.x = staticOrigin +  slideAmount * (CGRectGetMaxX(currentFrame) - staticOrigin);
        self.rightViewContainer.frame = sideFrame;
    }
    
    if (leftChanged || rightChanged) {
        [self notifyAnimationDelegatesWithLeftChanged:leftChanged rightChanged:rightChanged];
    }
}

#pragma mark - API

- (void)showFrontViewController
{
    [self showViewController:self.frontViewController];
}

- (void)showLeftViewController
{
    [self showViewController:self.leftViewController];
}

- (void)showRightViewController
{
    [self showViewController:self.rightViewController];
}

- (void)showViewController:(UIViewController *)controller
{
    [self showViewController:controller
                    animated:YES
                  completion:NULL];
}

- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion
{
    if (controller == self.leftViewController)
    {
        if ([self hasLeftViewController])
        {
            [self showLeftViewControllerAnimated:animated completion:completion];
        }
        
    }
    else if (controller == self.rightViewController)
    {
        if ([self hasRightViewController])
        {
            [self showRightViewControllerAnimated:animated completion:completion];
        }
    }
    else if (controller == self.frontViewController)
    {
        [self showFrontViewControllerAnimated:animated completion:completion];
    }
}


- (void)enterPresentationModeAnimated:(BOOL)animated
                           completion:(PKDefaultCompletionHandler)completion
{
    if ([self isLeftViewVisible])
    {
        [self enterPresentationModeForLeftViewControllerAnimated:animated
                                                      completion:completion];
    }
    else if ([self isRightViewVisible])
    {
        [self enterPresentationModeForRightViewControllerAnimated:animated
                                                       completion:completion];
    }
}

- (void)resignPresentationModeEntirely:(BOOL)entirely
                              animated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    if ([self isLeftViewVisible])
    {
        [self resignPresentationModeForLeftViewControllerEntirely:entirely
                                                         animated:animated
                                                       completion:completion];
    }
    else if ([self isRightViewVisible])
    {
        [self resignPresentationModeForRightViewControllerEntirely:entirely
                                                          animated:animated
                                                        completion:completion];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
    if (_frontViewController != frontViewController)
    {
        [self removeFrontViewControllerFromHierarchy];
        
        _frontViewController = frontViewController;
        _frontViewController.revealController = self;
        
        [self addFrontViewControllerToHierarchy];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion
{
    [self setFrontViewController:frontViewController];
    
    if (focus && ([self isLeftViewVisible] || [self isRightViewVisible]))
    {
        [self showViewController:self.frontViewController
                        animated:YES
                      completion:completion];
    }
    else
    {
        safelyExecuteCompletionBlockOnMainThread(completion, YES);
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != leftViewController)
    {
        if ([self isLeftViewVisible])
        {
            [self removeLeftViewControllerFromHierarchy];
        }
        
        _leftViewController = leftViewController;
        _leftViewController.revealController = self;
        
        if ([self isLeftViewVisible])
        {
            [self removeRightViewControllerFromHierarchy];
            [self addLeftViewControllerToHierarchy];
        }
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    BOOL isRightViewVisible = (self.state == PKRevealControllerFocusesRightViewController);
    
    if (_rightViewController != rightViewController)
    {
        if (isRightViewVisible)
        {
            [self removeRightViewControllerFromHierarchy];
        }
        
        _rightViewController = rightViewController;
        _rightViewController.revealController = self;
        
        if (isRightViewVisible)
        {
            [self removeLeftViewControllerFromHierarchy];
            [self addRightViewControllerToHierarchy];
        }
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

- (BOOL)hasRightViewController
{
    return PKRevealControllerTypeRight == (self.type & PKRevealControllerTypeRight);
}

- (BOOL)hasLeftViewController
{
    return PKRevealControllerTypeLeft == (self.type & PKRevealControllerTypeLeft);
}

- (void)setShadowColor:(UIColor *)color
                offset:(CGSize)offset
               opacity:(CGFloat)opacity
                radius:(CGFloat)radius
         forRevealSide:(PKRevealControllerType)revealSide
{
    if (self.frontViewContainer == nil)
    {
        [self initializeFrontViewContainer];
    }
    [self.frontViewContainer setShadowColor:color offset:offset opacity:opacity radius:radius forRevealSide:revealSide];
}

- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller
{
    NSRange widthRange = NSMakeRange(minWidth, maxWidth);
    
    if (controller == self.leftViewController)
    {
        self.leftViewWidthRange = widthRange;
    }
    else if (controller == self.rightViewController)
    {
        self.rightViewWidthRange = widthRange;
    }
}

- (CGFloat)minimumWidthForViewController:(UIViewController *)controller
{
    if (controller == self.leftViewController)
    {
        return self.leftViewWidthRange.location;
    }
    else if (controller == self.rightViewController)
    {
        return self.rightViewWidthRange.location;
    }
    else
    {
        return 0.0f;
    }
}

- (CGFloat)maximumWidthForViewController:(UIViewController *)controller
{
    if (controller == self.leftViewController)
    {
        return NSMaxRange(self.leftViewWidthRange);
    }
    else if (controller == self.rightViewController)
    {
        return NSMaxRange(self.rightViewWidthRange);
    }
    else
    {
        return 0.0f;
    }
}

- (UIViewController *)focusedController
{
    UIViewController *returnViewController = nil;
    switch (self.state)
    {
        case PKRevealControllerFocusesFrontViewController:
            returnViewController = self.frontViewController;
            break;
            
        case PKRevealControllerFocusesLeftViewController:
            returnViewController =  self.leftViewController;
            break;
            
        case PKRevealControllerFocusesRightViewController:
            returnViewController = self.rightViewController;
            break;
            
        case PKRevealControllerFocusesLeftViewControllerInPresentationMode:
        case PKRevealControllerFocusesRightViewControllerInPresentationMode:
            break;
    }
    return returnViewController;
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
    
    [self addFrontViewControllerToHierarchy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - View Lifecycle (Controller)

- (void)initializeFrontViewContainer
{
    if (self.frontViewContainer == nil)
    {
        self.frontViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.frontViewController shadow:YES];
        self.frontViewContainer.autoresizingMask = [self autoresizingMaskForFrontViewContainer];
    }
}

- (void)addFrontViewControllerToHierarchy
{
    if (self.frontViewController != nil && ![self.childViewControllers containsObject:self.frontViewController])
    {
        [self addChildViewController:self.frontViewController];
        self.frontViewContainer.viewController = self.frontViewController;
        
        if (self.frontViewContainer == nil)
        {
            [self initializeFrontViewContainer];
        }
        if (self.frontViewContainer.viewController != self.frontViewController)
        {
            self.frontViewContainer.viewController = self.frontViewController;
        }
        
        self.frontViewContainer.delegate = self;
        
        self.frontViewContainer.frame = [self frontViewFrameForCurrentState];
        [self.view addSubview:self.frontViewContainer];
        [self.frontViewController didMoveToParentViewController:self];
        
        [self updatePanGestureRecognizers];
    }
}

- (void)removeFrontViewControllerFromHierarchy
{
    if ([self.childViewControllers containsObject:self.frontViewController])
    {
        [self removePanGestureRecognizerFromFrontView];
        [self.frontViewContainer removeFromSuperview];
        [self.frontViewController removeFromParentViewController];
        self.frontViewContainer.delegate = nil;
    }
}

- (void)addLeftViewControllerToHierarchy
{
    if (self.leftViewController != nil && ![self.childViewControllers containsObject:self.leftViewController])
    {
        [self addChildViewController:self.leftViewController];
        self.leftViewContainer.viewController = self.leftViewController;
        
        if (self.leftViewContainer == nil)
        {
            self.leftViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.leftViewController shadow:NO];
            self.leftViewContainer.autoresizingMask = [self autoresizingMaskForLeftViewContainer];
            
            [self updatePanGestureRecognizers];
        }
        
        self.leftViewContainer.frame = [self leftViewFrame];
        [self.view insertSubview:self.leftViewContainer belowSubview:self.frontViewContainer];
        [self.leftViewController didMoveToParentViewController:self];
    }
}

- (void)removeLeftViewControllerFromHierarchy
{
    if ([self.childViewControllers containsObject:self.leftViewController])
    {
        [self.leftViewContainer removeFromSuperview];
        [self.leftViewController removeFromParentViewController];
    }
}

- (void)addRightViewControllerToHierarchy
{
    if (self.rightViewController != nil && ![self.childViewControllers containsObject:self.rightViewController])
    {
        [self addChildViewController:self.rightViewController];
        self.rightViewContainer.viewController = self.rightViewController;
        
        if (self.rightViewContainer == nil)
        {
            self.rightViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.rightViewController shadow:NO];
            self.rightViewContainer.autoresizingMask = [self autoresizingMaskForRightViewContainer];
            
            [self updatePanGestureRecognizers];
        }
        
        self.rightViewContainer.frame = [self rightViewFrame];
        [self.view insertSubview:self.rightViewContainer belowSubview:self.frontViewContainer];
        [self.rightViewController didMoveToParentViewController:self];
    }
}

- (void)removeRightViewControllerFromHierarchy
{
    if ([self.childViewControllers containsObject:self.rightViewController])
    {
        [self.rightViewContainer removeFromSuperview];
        [self.rightViewController removeFromParentViewController];
    }
}

#pragma mark Pan Gestures

- (void)addPanGestureRecognizerToFrontView
{
    [self.frontViewContainer addGestureRecognizer:self.revealFrontPanGestureRecognizer];
}

- (void)removePanGestureRecognizerFromFrontView
{
    if ([[self.frontViewContainer gestureRecognizers] containsObject:self.revealFrontPanGestureRecognizer])
    {
        [self.frontViewContainer removeGestureRecognizer:self.revealFrontPanGestureRecognizer];
    }
}

- (void)addPanGestureRecognizerToLeftView
{
    [self.leftViewContainer addGestureRecognizer:self.revealLeftPanGestureRecognizer];
}

- (void)removePanGestureRecognizerFromLeftView
{
    if ([[self.leftViewContainer gestureRecognizers] containsObject:self.revealLeftPanGestureRecognizer])
    {
        [self.leftViewContainer removeGestureRecognizer:self.revealLeftPanGestureRecognizer];
    }
}

- (void)addPanGestureRecognizerToRightView
{
    [self.rightViewContainer addGestureRecognizer:self.revealRightPanGestureRecognizer];
}

- (void)removePanGestureRecognizerFromRightView
{
    if ([[self.rightViewContainer gestureRecognizers] containsObject:self.revealRightPanGestureRecognizer])
    {
        [self.rightViewContainer removeGestureRecognizer:self.revealRightPanGestureRecognizer];
    }
}

- (void)updatePanGestureRecognizers
{
    if (self.recognizesPanningOnFrontView)
    {
        [self addPanGestureRecognizerToFrontView];
    }
    else
    {
        [self removePanGestureRecognizerFromFrontView];
    }
    
    if (self.recognizesPanningOnLeftView)
    {
        [self addPanGestureRecognizerToLeftView];
    }
    else
    {
        [self removePanGestureRecognizerFromLeftView];
    }
    
    if (self.recognizesPanningOnRightView)
    {
        [self addPanGestureRecognizerToRightView];
    }
    else
    {
        [self removePanGestureRecognizerFromRightView];
    }
}

#pragma mark Tap Gestures

- (void)addTapGestureRecognizerToFrontView
{
    [self.frontViewContainer addGestureRecognizer:self.revealResetTapGestureRecognizer];
}

- (void)removeTapGestureRecognizerFromFrontView
{
    if ([[self.frontViewContainer gestureRecognizers] containsObject:self.revealResetTapGestureRecognizer])
    {
        [self.frontViewContainer removeGestureRecognizer:self.revealResetTapGestureRecognizer];
    }
}

- (void)updateResetTapGestureRecognizer
{
    if (self.recognizesResetTapOnFrontView
        && (self.state != PKRevealControllerFocusesFrontViewController))
    {
        [self addTapGestureRecognizerToFrontView];
    }
    else
    {
        [self removeTapGestureRecognizerFromFrontView];
    }
}

#pragma mark - Setup

- (void)setup
{
    self.state = PKRevealControllerFocusesFrontViewController;
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (void)setupViewControllers
{
    [self addFrontViewControllerToHierarchy];
}

- (void)setupPanGestureRecognizer
{
    SEL panRecognitionCallback = @selector(didRecognizePanWithGestureRecognizer:);
    self.revealFrontPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:panRecognitionCallback];
    self.revealFrontPanGestureRecognizer.delegate = self;
    self.revealLeftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:panRecognitionCallback];
    self.revealLeftPanGestureRecognizer.delegate = self;
    self.revealRightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:panRecognitionCallback];
    self.revealRightPanGestureRecognizer.delegate = self;
}

- (void)setupTapGestureRecognizer
{
    SEL tapRecognitionCallback = @selector(didRecognizeTapWithGestureRecognizer:);
    self.revealResetTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:tapRecognitionCallback];
    self.revealResetTapGestureRecognizer.delegate = self;
}

#pragma mark - Options

- (NSDictionary *)options
{
    return (NSDictionary *)self.controllerOptions;
}

#pragma mark -

- (CGFloat)animationDuration
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationDurationKey];
    
    if (number == nil)
    {
        [self setAnimationDuration:DEFAULT_ANIMATION_DURATION_VALUE];
        return [self animationDuration];
    }
    else
    {
        return [number floatValue];
    }
}

- (void)setAnimationDuration:(CGFloat)animationDuration
{
    [self.controllerOptions setObject:[NSNumber numberWithFloat:animationDuration]
                               forKey:PKRevealControllerAnimationDurationKey];
}

#pragma mark -

- (UIViewAnimationCurve)animationCurve
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationCurveKey];
    
    if (number == nil)
    {
        [self setAnimationCurve:DEFAULT_ANIMATION_CURVE_VALUE];
        return [self animationCurve];
    }
    else
    {
        return (UIViewAnimationCurve)[number integerValue];
    }
}

- (void)setAnimationCurve:(UIViewAnimationCurve)animationCurve
{
    [self.controllerOptions setObject:[NSNumber numberWithInteger:animationCurve]
                               forKey:PKRevealControllerAnimationCurveKey];
}

#pragma mark -

- (PKRevealControllerAnimationType)animationType
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationTypeKey];
    
    if (number == nil)
    {
        [self setAnimationType:DEFAULT_ANIMATION_TYPE_VALUE];
        return [self animationType];
    }
    else
    {
        return (PKRevealControllerAnimationType)[number integerValue];
    }
}

- (void)setAnimationType:(PKRevealControllerAnimationType)animationType
{
    [self.controllerOptions setObject:[NSNumber numberWithInteger:animationType]
                               forKey:PKRevealControllerAnimationTypeKey];
}

#pragma mark -

- (BOOL)allowsOverdraw
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAllowsOverdrawKey];
    
    if (number == nil)
    {
        [self setAllowsOverdraw:DEFAULT_ALLOWS_OVERDRAW_VALUE];
        return [self allowsOverdraw];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setAllowsOverdraw:(BOOL)allowsOverdraw
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:allowsOverdraw]
                               forKey:PKRevealControllerAllowsOverdrawKey];
}

#pragma mark -

- (void)setQuickSwipeVelocity:(CGFloat)quickSwipeVelocity
{
    [self.controllerOptions setObject:[NSNumber numberWithFloat:quickSwipeVelocity]
                               forKey:PKRevealControllerQuickSwipeToggleVelocityKey];
}

- (CGFloat)quickSwipeVelocity
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerQuickSwipeToggleVelocityKey];
    
    if (number == nil)
    {
        [self setQuickSwipeVelocity:DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE];
        return [self quickSwipeVelocity];
    }
    else
    {
        return [number floatValue];
    }
}

#pragma mark -

- (BOOL)disablesFrontViewInteraction
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerDisablesFrontViewInteractionKey];
    
    if (number == nil)
    {
        [self setDisablesFrontViewInteraction:DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE];
        return [self disablesFrontViewInteraction];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setDisablesFrontViewInteraction:(BOOL)disablesFrontViewInteraction
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:disablesFrontViewInteraction]
                               forKey:PKRevealControllerDisablesFrontViewInteractionKey];
}

#pragma mark -

- (void)setRecognizesPanningOnFrontView:(BOOL)recognizesPanningOnFrontView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesPanningOnFrontView]
                               forKey:PKRevealControllerRecognizesPanningOnFrontViewKey];
    [self updatePanGestureRecognizers];
}

- (BOOL)recognizesPanningOnFrontView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesPanningOnFrontViewKey];
    
    if (number == nil)
    {
        [self setRecognizesPanningOnFrontView:DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE];
        return [self recognizesPanningOnFrontView];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setRecognizesPanningOnLeftView:(BOOL)recognizesPanningOnLeftView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesPanningOnLeftView]
                               forKey:PKRevealControllerRecognizesPanningOnLeftViewKey];
    [self updatePanGestureRecognizers];
}

- (BOOL)recognizesPanningOnLeftView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesPanningOnLeftViewKey];
    
    if (number == nil)
    {
        [self setRecognizesPanningOnLeftView:DEFAULT_RECOGNIZES_PAN_ON_LEFT_VIEW_VALUE];
        return [self recognizesPanningOnLeftView];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setRecognizesPanningOnRightView:(BOOL)recognizesPanningOnRightView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesPanningOnRightView]
                               forKey:PKRevealControllerRecognizesPanningOnRightViewKey];
    [self updatePanGestureRecognizers];
}

- (BOOL)recognizesPanningOnRightView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesPanningOnRightViewKey];
    
    if (number == nil)
    {
        [self setRecognizesPanningOnRightView:DEFAULT_RECOGNIZES_PAN_ON_RIGHT_VIEW_VALUE];
        return [self recognizesPanningOnRightView];
    }
    else
    {
        return [number boolValue];
    }
}

#pragma mark -

- (void)setRecognizesResetTapOnFrontView:(BOOL)recognizesResetTapOnFrontView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesResetTapOnFrontView]
                               forKey:PKRevealControllerRecognizesResetTapOnFrontViewKey];
    [self updateResetTapGestureRecognizer];
}

- (BOOL)recognizesResetTapOnFrontView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesResetTapOnFrontViewKey];
    
    if (number == nil)
    {
        [self setRecognizesResetTapOnFrontView:DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE];
        return [self recognizesResetTapOnFrontView];
    }
    else
    {
        return [number boolValue];
    }
}

#pragma mark - Gesture Recognition

- (void)didRecognizeTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self showViewController:self.frontViewController];
}

- (void)didRecognizePanWithGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handleGestureBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self handleGestureChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self handleGestureEndedWithRecognizer:recognizer];
            break;
                        
        default:
        {
            recognizer.enabled = YES;
        }
            break;
    }
}

#pragma mark - Gesture Handling

- (void)handleGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.initialTouchLocation = [recognizer locationInView:self.view];
    self.previousTouchLocation = self.initialTouchLocation;
}

- (void)handleGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self.view];
    CGFloat delta = currentTouchLocation.x - self.previousTouchLocation.x;
    self.previousTouchLocation = currentTouchLocation;
    
    [self translateViewsBy:delta animationType:[self animationType]];
    [self adjustLeftAndRightViewVisibilities];
}

- (void)handleGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat velocity = [recognizer velocityInView:self.view].x;
    
    if ([self shouldMoveFrontViewRightwardsForVelocity:velocity])
    {
        [self moveFrontViewRightwardsIfPossible];
    }
    else if ([self shouldMoveFrontViewLeftwardsForVelocity:velocity])
    {
        [self moveFrontViewLeftwardsIfPossible];
    }
    else
    {
        [self snapFrontViewToClosestEdge];
    }
    
    recognizer.enabled = YES;
}

#pragma mark - Gesture Delegation

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.revealFrontPanGestureRecognizer)
    {
        CGPoint translation = [self.revealFrontPanGestureRecognizer translationInView:self.frontViewContainer];
        return (fabs(translation.x) >= fabs(translation.y));
    }
    else if (gestureRecognizer == self.revealLeftPanGestureRecognizer && ![self isLeftViewVisible])
    {
        return NO;
    }
    else if (gestureRecognizer == self.revealRightPanGestureRecognizer && ![self isRightViewVisible])
    {
        return NO;
    }
    else if (gestureRecognizer == self.revealResetTapGestureRecognizer)
    {
        return ([self isLeftViewVisible] || [self isRightViewVisible]);
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
    BOOL positiveTranslationDoesNotExceedMinWidth = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMinWidth]);
    BOOL positiveTranslationDoesNotExceedMaxWidth = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMaxWidthRespectingOverdraw:YES]);
    
    BOOL isNegativeTranslation = (translation < CGRectGetMinX(frameForFrontViewCenter));
    BOOL negativeTranslationDoesNotExceedMinWidth = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMinWidth]);
    BOOL negativeTranslationDoesNotExceedMaxWidth = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMaxWidthRespectingOverdraw:YES]);
    
    BOOL isLegalNormalTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedMinWidth)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedMinWidth);
    
    BOOL isLegalOverdrawTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedMaxWidth)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedMaxWidth);
    
    if (isLegalNormalTranslation || isLegalOverdrawTranslation)
    {
        BOOL isOverdrawing = (!isLegalNormalTranslation && isLegalOverdrawTranslation);
        
        if (animationType == PKRevealControllerAnimationTypeStatic)
        {
            [self translateFrontViewBy:delta
                         isOverdrawing:isOverdrawing];
        }
    }
}

- (void)translateFrontViewBy:(CGFloat)delta isOverdrawing:(BOOL)overdraw
{
    CGRect frame = self.frontViewContainer.frame;
    
    if (overdraw && self.allowsOverdraw)
    {
        frame.origin.x = floorf(frame.origin.x + (delta / 2.0f));
    }
    else if (!overdraw)
    {
        frame.origin.x += delta;
    }
    
    self.frontViewContainer.frame = frame;
}

- (void)moveFrontViewRightwardsIfPossible
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isNegative(origin.x))
    {
        [self showViewController:self.frontViewController];
    }
    else if (isZero(origin.x))
    {
        [self showViewController:self.leftViewController];
    }
    else
    {
        [self showViewController:self.leftViewController];
    }
}

- (void)moveFrontViewLeftwardsIfPossible
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isNegative(origin.x))
    {
        [self showViewController:self.rightViewController];
    }
    else if (isZero(origin.x))
    {
        [self showViewController:self.rightViewController];
    }
    else
    {
        [self showViewController:self.frontViewController];
    }
}

#pragma mark - Helper (Internal)

- (void)showLeftViewControllerAnimated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    void (^showLeftViewBlock)(BOOL finished) = ^(BOOL finished)
    {
        [weakSelf removeRightViewControllerFromHierarchy];
        [weakSelf addLeftViewControllerToHierarchy];
        
        [weakSelf setFrontViewFrame:[weakSelf frontViewFrameForVisibleLeftView]
                           animated:animated
                         completion:^(BOOL finished)
         {
             if (weakSelf.disablesFrontViewInteraction)
             {
                 [weakSelf.frontViewContainer disableUserInteractionForContainedView];
             }
             weakSelf.state = PKRevealControllerFocusesLeftViewController;
             [weakSelf removeRightViewControllerFromHierarchy];
             [weakSelf updateResetTapGestureRecognizer];
             [weakSelf notifyDelegateDidShowViewController:weakSelf.leftViewController animated:animated];
             safelyExecuteCompletionBlockOnMainThread(completion, finished);
         }];
    };
    
    if ([self isRightViewVisible])
    {
        [self showFrontViewControllerAnimated:animated
                                   completion:^(BOOL finished)
        {
            showLeftViewBlock(finished);
        }];
    }
    else
    {
        showLeftViewBlock(YES);
    }
}


- (void)showRightViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    void (^showRightViewBlock)(BOOL finished) = ^(BOOL finished)
    {
        [weakSelf removeLeftViewControllerFromHierarchy];
        [weakSelf addRightViewControllerToHierarchy];
        
        [weakSelf setFrontViewFrame:[weakSelf frontViewFrameForVisibleRightView]
                           animated:animated
                         completion:^(BOOL finished)
        {
            if (weakSelf.disablesFrontViewInteraction)
            {
                [weakSelf.frontViewContainer disableUserInteractionForContainedView];
            }
            weakSelf.state = PKRevealControllerFocusesRightViewController;
            [weakSelf updateResetTapGestureRecognizer];
            [weakSelf notifyDelegateDidShowViewController:weakSelf.rightViewController animated:animated];
            safelyExecuteCompletionBlockOnMainThread(completion, finished);
        }];
    };
    
    if ([self isLeftViewVisible])
    {
        [self showFrontViewControllerAnimated:animated
                                   completion:^(BOOL finished)
        {
            showRightViewBlock(finished);
        }];
    }
    else
    {
        showRightViewBlock(YES);
    }
}


- (void)showFrontViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForCenter]
                   animated:animated
                 completion:^(BOOL finished)
     {
         if (weakSelf.disablesFrontViewInteraction)
         {
             [weakSelf.frontViewContainer enableUserInteractionForContainedView];
         }
         weakSelf.state = PKRevealControllerFocusesFrontViewController;
         [weakSelf removeRightViewControllerFromHierarchy];
         [weakSelf removeLeftViewControllerFromHierarchy];
         [weakSelf updateResetTapGestureRecognizer];
         [weakSelf notifyDelegateDidShowViewController:weakSelf.frontViewController animated:animated];
         safelyExecuteCompletionBlockOnMainThread(completion, finished);
     }];
}

- (void)enterPresentationModeForLeftViewControllerAnimated:(BOOL)animated
                                                completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForLeftViewPresentationMode]
                   animated:animated
                 completion:^(BOOL finished)
    {
        weakSelf.state = PKRevealControllerFocusesLeftViewControllerInPresentationMode;
        safelyExecuteCompletionBlockOnMainThread(completion, finished);
    }];
}

- (void)enterPresentationModeForRightViewControllerAnimated:(BOOL)animated
                                                 completion:(PKDefaultCompletionHandler)completion
{
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForRightViewPresentationMode]
                   animated:animated
                 completion:^(BOOL finished)
    {
        weakSelf.state = PKRevealControllerFocusesRightViewControllerInPresentationMode;
        safelyExecuteCompletionBlockOnMainThread(completion, finished);
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
                 completion:^(BOOL finished)
    {
        weakSelf.state = state;
        safelyExecuteCompletionBlockOnMainThread(completion, finished);
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
    
    [self setFrontViewFrame:frame animated:animated completion:^(BOOL finished)
    {
        weakSelf.state = state;
        safelyExecuteCompletionBlockOnMainThread(completion, finished);
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
        [self setFrontViewFrameLinearly:frame
                               animated:animated
                               duration:duration
                                options:options
                             completion:completion];
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
        safelyExecuteCompletionBlockOnMainThread(completion, finished);
    }];
}

#pragma mark - Helpers (Options)

- (BOOL)booleanPropertyForKey:(NSString *)aKey default:(BOOL)defaultValue
{
    if (aKey == nil) return defaultValue;
    
    NSNumber *number = [_controllerOptions objectForKey:aKey];
    if ([number isKindOfClass:[NSNumber class]]) {
        return number.boolValue;
    } else {
        return defaultValue;
    }
}

- (CGFloat)floatPropertyForKey:(NSString *)aKey default:(CGFloat)defaultValue
{
    if (aKey == nil) return defaultValue;
    
    NSNumber *number = [_controllerOptions objectForKey:aKey];
    if ([number isKindOfClass:[NSNumber class]]) {
        return number.floatValue;
    } else {
        return defaultValue;
    }
}

#pragma mark - Helpers (Gestures)

- (BOOL)shouldMoveFrontViewRightwardsForVelocity:(CGFloat)velocity
{
    return (isPositive(velocity) && velocity > self.quickSwipeVelocity);
}

- (BOOL)shouldMoveFrontViewLeftwardsForVelocity:(CGFloat)velocity
{
    return (isNegative(velocity) && fabsf(velocity) > self.quickSwipeVelocity);
}

- (void)snapFrontViewToClosestEdge
{
    UIViewController *controllerToShow = nil;
    
    if ([self isLeftViewVisible])
    {
        CGRect relevantLeftViewRect = self.leftViewContainer.frame;
        relevantLeftViewRect.size.width = [self leftViewMinWidth];
        
        BOOL showLeftView = CGRectGetWidth(CGRectIntersection(self.frontViewContainer.frame, relevantLeftViewRect)) <= floorf(CGRectGetWidth(relevantLeftViewRect)/2.0f);
        controllerToShow = showLeftView ? self.leftViewController : self.frontViewController;
    }
    else if ([self isRightViewVisible])
    {
        CGRect relevantRightViewRect = self.rightViewContainer.frame;
        relevantRightViewRect.origin.x += CGRectGetWidth(self.rightViewContainer.frame)-[self rightViewMinWidth];
        relevantRightViewRect.size.width = [self rightViewMinWidth];
        
        BOOL showRightView = CGRectGetWidth(CGRectIntersection(self.frontViewContainer.frame, relevantRightViewRect)) <= floorf(CGRectGetWidth(relevantRightViewRect)/2.0f);
        controllerToShow = showRightView ? self.rightViewController : self.frontViewController;
    }
    else
    {
        controllerToShow = self.frontViewController;
    }
    
    [self showViewController:controllerToShow];
}

#pragma mark - Helpers (States)

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
        [self removeRightViewControllerFromHierarchy];
        [self addLeftViewControllerToHierarchy];
    }
    else
    {
        [self removeLeftViewControllerFromHierarchy];
        [self addRightViewControllerToHierarchy];
    }
}

#pragma mark - Helper (Sizing)

- (CGFloat)leftViewMaxWidthRespectingOverdraw:(BOOL)respectOverdraw
{
    if (respectOverdraw)
    {
        return self.allowsOverdraw ? self.leftViewWidthRange.length : [self leftViewMinWidth];
    }
    else
    {
        return self.leftViewWidthRange.length;
    }
}

- (CGFloat)rightViewMaxWidthRespectingOverdraw:(BOOL)respectOverdraw
{
    if (respectOverdraw)
    {
        return self.allowsOverdraw ? self.rightViewWidthRange.length : [self rightViewMinWidth];
    }
    else
    {
        return self.rightViewWidthRange.length;
    }
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
    CGRect returnRect = CGRectNull;
    switch (self.state)
    {
        case PKRevealControllerFocusesFrontViewController:
            returnRect = [self frontViewFrameForCenter];
            break;
            
        case PKRevealControllerFocusesLeftViewController:
            returnRect = [self frontViewFrameForVisibleLeftView];
            break;
            
        case PKRevealControllerFocusesRightViewController:
            returnRect = [self frontViewFrameForVisibleRightView];
            break;
            
        case PKRevealControllerFocusesLeftViewControllerInPresentationMode:
        case PKRevealControllerFocusesRightViewControllerInPresentationMode:
            break;
    }
    
    return returnRect;
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
    frame.origin.x = [self leftViewMaxWidthRespectingOverdraw:NO];
    return frame;
}

- (CGRect)frontViewFrameForRightViewPresentationMode
{
    CGRect frame = [self frontViewFrameForCenter];
    frame.origin.x = -[self rightViewMaxWidthRespectingOverdraw:NO];
    return frame;
}

- (CGRect)leftViewFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake([self leftViewMaxWidthRespectingOverdraw:NO], CGRectGetHeight(self.view.bounds));
    frame.origin = CGPointZero;
    return frame;
}

- (CGRect)rightViewFrame
{
    CGRect frame = self.frontViewContainer.bounds;
    
    if (self.animationType == PKRevealControllerAnimationTypeStatic)
    {
        frame.size = CGSizeMake([self rightViewMaxWidthRespectingOverdraw:NO], CGRectGetHeight(self.view.bounds));
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
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
    return (value > 0.0f);
}

NS_INLINE BOOL isNegative(CGFloat value)
{
    return (value < 0.0f);
}

NS_INLINE BOOL isZero(CGFloat value)
{
    return (value == 0.0f);
}

NS_INLINE void safelyExecuteCompletionBlockOnMainThread(PKDefaultCompletionHandler block, BOOL finished)
{
    void(^executeBlock)() = ^()
    {
        if (block != NULL)
        {
            block(finished);
        }
    };
    
    if ([NSThread isMainThread])
    {
        executeBlock();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), executeBlock);
    }
}

@end
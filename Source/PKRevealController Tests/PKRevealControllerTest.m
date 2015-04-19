//
//  PKRevealControllerTest.m
//  PKRevealController
//
//  Created by Nataliya Patsovska on 4/18/15.
//  Copyright (c) 2015 zuui.org (Philip Kluz). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PKRevealController.h"

@interface PKRevealController (PKRevealControllerTest)

- (BOOL)isLeftViewVisible;
- (BOOL)isRightViewVisible;

- (CGFloat)leftViewMinWidth;
- (CGFloat)leftViewMaxWidth;

- (CGFloat)rightViewMinWidth;
- (CGFloat)rightViewMaxWidth;

- (CALayer *)frontViewLayer;

@end

@interface PKRevealControllerTest : XCTestCase

@property PKRevealController *revealController;

@end

@implementation PKRevealControllerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Initializers
- (void)testInitWithFrontController
{
    // given
    UIViewController *frontVC = [UIViewController new];
    
    // when
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                     leftViewController:nil
                                                                    rightViewController:nil];
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertEqualObjects(self.revealController.frontViewController, frontVC);
    XCTAssertFalse(self.revealController.hasLeftViewController);
    XCTAssertFalse(self.revealController.hasRightViewController);
}

// since all VCs are readwrite they could be setup later
- (void)testThatInitWithoutAnyControllersDoesNotThrow
{
    // when
    XCTAssertNoThrow(self.revealController = [PKRevealController revealControllerWithFrontViewController:nil leftViewController:nil rightViewController:nil]);
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertNil(self.revealController.frontViewController);
    XCTAssertFalse(self.revealController.hasLeftViewController);
    XCTAssertFalse(self.revealController.hasRightViewController);
}

- (void)testInitWithLeftAndRightControllers
{
    // given
    UIViewController *frontVC = [UIViewController new];
    UIViewController *leftVC = [UIViewController new];
    UIViewController *rightVC = [UIViewController new];
    
    // when
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                     leftViewController:leftVC
                                                                    rightViewController:rightVC];
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertEqualObjects(self.revealController.frontViewController, frontVC);
    XCTAssertEqualObjects(self.revealController.leftViewController, leftVC);
    XCTAssertEqualObjects(self.revealController.rightViewController, rightVC);
}

- (void)testInitWithRightController
{
    // given
    UIViewController *frontVC = [UIViewController new];
    UIViewController *rightVC = [UIViewController new];
    
    // when
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                    rightViewController:rightVC];
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertEqualObjects(self.revealController.frontViewController, frontVC);
    XCTAssertEqualObjects(self.revealController.rightViewController, rightVC);
    
    XCTAssertTrue(self.revealController.hasRightViewController);
    XCTAssertFalse(self.revealController.hasLeftViewController);
}

- (void)testInitWithLeftController
{
    // given
    UIViewController *frontVC = [UIViewController new];
    UIViewController *leftVC = [UIViewController new];
    
    // when
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                     leftViewController:leftVC];
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertEqualObjects(self.revealController.frontViewController, frontVC);
    XCTAssertEqualObjects(self.revealController.leftViewController, leftVC);
    
    XCTAssertTrue(self.revealController.hasLeftViewController);
    XCTAssertFalse(self.revealController.hasRightViewController);
}

#pragma mark - Showing controllers
- (void)testThatShowControllerChangesStateProperlyForFrontLeftAndRightControllers
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewController);
    XCTAssertTrue([self.revealController isLeftViewVisible]);
    XCTAssertFalse([self.revealController isRightViewVisible]);
    XCTAssertFalse(self.revealController.frontViewController.view.userInteractionEnabled);
    
    [self.revealController showViewController:self.revealController.rightViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsRightViewController);
    XCTAssertFalse([self.revealController isLeftViewVisible]);
    XCTAssertTrue([self.revealController isRightViewVisible]);
    XCTAssertFalse(self.revealController.frontViewController.view.userInteractionEnabled);
    
    [self.revealController showViewController:self.revealController.frontViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsFrontViewController);
    XCTAssertFalse([self.revealController isLeftViewVisible]);
    XCTAssertFalse([self.revealController isRightViewVisible]);
    XCTAssertTrue(self.revealController.frontViewController.view.userInteractionEnabled);
}

- (void)testThatShowControllerDoesntChangeStateForInvalidControllers
{
    // given
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
    
    // when trying to show new controller (not left or right)
    UIViewController *controller = [UIViewController new];
    [self.revealController showViewController:controller animated:NO completion:nil];
    
    // then verify state not changed
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewController);
    
    // when trying to show nil controller
    [self.revealController showViewController:nil animated:NO completion:nil];
    
    // then verify state not changed
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewController);
}

- (void)testShowControllerAnimatedCompletionCalledForValidController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self showRightControllerAndVerifyCompletionIsCalledAnimated:YES];
}

- (void)testShowControllerAnimatedCompletionCalledForInvalidController
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self showRightControllerAndVerifyCompletionIsCalledAnimated:YES];
}

- (void)testShowControllerCompletionCalledEvenWithoutAnimation
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self showRightControllerAndVerifyCompletionIsCalledAnimated:NO];
}

#pragma mark - Presentation mode
- (void)testEnterPresentationModeFailureWithoutSideControllers
{
    self.revealController = [PKRevealController new];
    [self.revealController view];
    
    [self enterPresentationModeAndVerifyActiveStatus:NO animated:YES];
}

- (void)testEnterPresentationModeFailureWithoutSpecifyingSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self enterPresentationModeAndVerifyActiveStatus:NO animated:YES];
}

- (void)testEnterPresentationModeSuccessByFirstShowingLeftSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
    
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeSuccessByFirstShowingRightSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self.revealController showViewController:self.revealController.rightViewController animated:NO completion:nil];
    
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeSuccessWithLeftSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeSuccessWithRightSideController
{
    [self defaultInitializerWithSideControllersLeft:NO right:YES];
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeCompletionCalledEvenWithoutAnimation
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:NO];
}

#pragma mark - Resigning presentation mode
- (void)testResignPresentationModeWithLeftSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewControllerInPresentationMode);
    
    [self.revealController resignPresentationModeEntirely:NO animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewController);
}

- (void)testResignPresentationModeWithRightSideController
{
    [self defaultInitializerWithSideControllersLeft:NO right:YES];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsRightViewControllerInPresentationMode);
    
    [self.revealController resignPresentationModeEntirely:NO animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsRightViewController);
}

- (void)testResignPresentationModeEntirelyWithLeftSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewControllerInPresentationMode);
    
    [self.revealController resignPresentationModeEntirely:YES animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsFrontViewController);
}

- (void)testResignPresentationModeEntirelyWithRightSideController
{
    [self defaultInitializerWithSideControllersLeft:NO right:YES];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsRightViewControllerInPresentationMode);
    
    [self.revealController resignPresentationModeEntirely:YES animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsFrontViewController);
}

- (void)testResignPresentationModeAnimatedCompletionCalled
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"resign presentation mode animated finished"];
    [self.revealController resignPresentationModeEntirely:YES animated:YES completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.01 handler:nil];
}

- (void)testResignPresentationModeCompletionCalledEvenWithoutAnimation
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"resign presentation mode animated finished"];
    [self.revealController resignPresentationModeEntirely:YES animated:NO completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.01 handler:nil];
}

#pragma mark - Min/max width
- (void)testThatMinMaxWidthConfigurationIsSavedForLeftSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self.revealController setMinimumWidth:100.0 maximumWidth:200.0 forViewController:self.revealController.leftViewController];
    
    XCTAssertEqualWithAccuracy([self.revealController leftViewMinWidth], 100.0, 0.001);
    XCTAssertEqualWithAccuracy([self.revealController leftViewMaxWidth], 200.0, 0.001);
}

- (void)testThatMinMaxWidthConfigurationIsSavedForRightSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self.revealController setMinimumWidth:100.0 maximumWidth:200.0 forViewController:self.revealController.rightViewController];
    
    XCTAssertEqualWithAccuracy([self.revealController rightViewMinWidth], 100.0, 0.001);
    XCTAssertEqualWithAccuracy([self.revealController rightViewMaxWidth], 200.0, 0.001);
}

- (void)testThatMinMaxWidthConfigurationDoesNotSaveInvalidData
{
    // given
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    
    // when max width is less than min width
    [self.revealController setMinimumWidth:100.0 maximumWidth:0.0 forViewController:self.revealController.leftViewController];
    
    // then assert that max value is equal to min value
    XCTAssertEqualWithAccuracy([self.revealController leftViewMinWidth], 100.0, 0.001);
    XCTAssertEqualWithAccuracy([self.revealController leftViewMaxWidth], 100.0, 0.001);
    
    // when min width is less than zero
    [self.revealController setMinimumWidth:-100.0 maximumWidth:100.0 forViewController:self.revealController.leftViewController];
    
    // then assert the default configuration
    XCTAssertEqualWithAccuracy([self.revealController leftViewMinWidth], 0.0, 0.001);
    XCTAssertEqualWithAccuracy([self.revealController leftViewMaxWidth], 100.0, 0.001);
}

- (void)testThatMinWidthIsUsedWhenControllerIsShown
{
    // given - min width:100, max width:200
    [self testThatMinMaxWidthConfigurationIsSavedForLeftSideController];
    
    // when
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
}

- (void)testThatMaxWidthIsUsedWhenControllerIsInPresentationMode
{
    // given - min width:100, max width:200
    [self testThatMinMaxWidthConfigurationIsSavedForLeftSideController];
    CGFloat initialPosition = self.revealController.frontViewLayer.position.x;
    
    // then
    XCTAssertEqualWithAccuracy(self.revealController.frontViewLayer.position.x - initialPosition, 100.0, 0.001);
    
    // when
    [self.revealController enterPresentationModeAnimated:NO completion:nil];
    
    // then
    XCTAssertEqualWithAccuracy(self.revealController.frontViewLayer.position.x - initialPosition, 200.0, 0.001);
}

#pragma mark - Retrieving reveal controller from managed controllers
- (void)testRetrievingRevealControllerForManagedControllers
{
    // given
    UIViewController *frontVC = [UIViewController new];
    UIViewController *leftVC = [UIViewController new];
    UIViewController *rightVC = [UIViewController new];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                     leftViewController:leftVC
                                                                    rightViewController:rightVC];
    XCTAssertNotNil(self.revealController);
    [self.revealController view];
    
    // then assert that reveal controller could be retrieved from managed controllers
    XCTAssertEqualObjects(self.revealController, frontVC.revealController);
    XCTAssertEqualObjects(self.revealController, leftVC.revealController);
    XCTAssertEqualObjects(self.revealController, rightVC.revealController);
    
    // when
    self.revealController.frontViewController = nil;
    self.revealController.leftViewController = nil;
    self.revealController.rightViewController = nil;
    
    // then assert that reveal controller could not be retrieved from managed controllers
    XCTAssertNil(frontVC.revealController);
    XCTAssertNil(leftVC.revealController);
    XCTAssertNil(rightVC.revealController);
}


#pragma mark - Helpers
- (void)defaultInitializerWithSideControllersLeft:(BOOL)useLeft right:(BOOL)useRight
{
    UIViewController *frontVC = [UIViewController new];
    UIViewController *leftVC = useLeft ? [UIViewController new] : nil;
    UIViewController *rightVC = useRight ? [UIViewController new] : nil;
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontVC
                                                                     leftViewController:leftVC
                                                                    rightViewController:rightVC];
    XCTAssertNotNil(self.revealController);
    
    [self.revealController view];
    
    // setup very fast animations for faster tests
    self.revealController.animationDuration = 0.001f;
}

- (void)verifyDefaultConfiguration
{
    XCTAssertNotNil(self.revealController);
    
    [self.revealController view];
    
    XCTAssertNotNil(self.revealController.revealPanGestureRecognizer);
    XCTAssertNotNil(self.revealController.revealResetTapGestureRecognizer);
    
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsFrontViewController);
    XCTAssertEqual(self.revealController.animationCurve, UIViewAnimationCurveLinear);
    XCTAssertEqual(self.revealController.animationType, PKRevealControllerAnimationTypeStatic);
    
    XCTAssertFalse(self.revealController.isPresentationModeActive);
    
    XCTAssertTrue(self.revealController.allowsOverdraw);
    XCTAssertTrue(self.revealController.disablesFrontViewInteraction);
    XCTAssertTrue(self.revealController.recognizesPanningOnFrontView);
    XCTAssertTrue(self.revealController.recognizesResetTapOnFrontView);
    XCTAssertTrue(self.revealController.recognizesResetTapOnFrontViewInPresentationMode);
    
    XCTAssertEqualWithAccuracy(self.revealController.animationDuration, 0.185, 0.0001);
    XCTAssertEqualWithAccuracy(self.revealController.quickSwipeVelocity, 800, 0.0001);
    XCTAssertEqualWithAccuracy([self.revealController leftViewMinWidth], 260.0, 0.001);
    XCTAssertEqualWithAccuracy([self.revealController leftViewMaxWidth], 300.0, 0.001);
}

- (void)showRightControllerAndVerifyCompletionIsCalledAnimated:(BOOL)animated
{
    NSString *expectationDescription = [NSString stringWithFormat:@"show controller%@ finished", animated ? @" animated" : @""];
    XCTestExpectation *expectation = [self expectationWithDescription:expectationDescription];
    
    [self.revealController showViewController:self.revealController.rightViewController animated:animated completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.01 handler:nil];
}

- (void)enterPresentationModeAndVerifyActiveStatus:(BOOL)active animated:(BOOL)animated
{
    NSString *expectationDescription = [NSString stringWithFormat:@"enter presentation mode%@ finished", animated ? @" animated" : @""];
    XCTestExpectation *expectation = [self expectationWithDescription:expectationDescription];
    
    [self.revealController enterPresentationModeAnimated:animated completion:^(BOOL finished) {
        [expectation fulfill];
        XCTAssertEqual(self.revealController.isPresentationModeActive, active);
    }];
    
    [self waitForExpectationsWithTimeout:0.01 handler:nil];
}

@end

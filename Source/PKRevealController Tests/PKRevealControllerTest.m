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
                                                                     leftViewController:nil
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
                                                                     leftViewController:leftVC
                                                                    rightViewController:nil];
    
    // then
    [self verifyDefaultConfiguration];
    
    XCTAssertEqualObjects(self.revealController.frontViewController, frontVC);
    XCTAssertEqualObjects(self.revealController.leftViewController, leftVC);
    
    XCTAssertTrue(self.revealController.hasLeftViewController);
    XCTAssertFalse(self.revealController.hasRightViewController);
}

#pragma mark - Showing controllers
- (void)testThatShowControllerChangesStateProperlyForFrontLeftAndRightController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsLeftViewController);
    
    [self.revealController showViewController:self.revealController.rightViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsRightViewController);
    
    [self.revealController showViewController:self.revealController.frontViewController animated:NO completion:nil];
    XCTAssertEqual(self.revealController.state, PKRevealControllerShowsFrontViewController);
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

#pragma mark - Test presentation mode
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

- (void)testEnterPresentationModeSuccessByFirstShowingSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:YES];
    [self.revealController showViewController:self.revealController.leftViewController animated:NO completion:nil];
    
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeSuccessWithOneSideController
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:YES];
}

- (void)testEnterPresentationModeCompletionCalledEvenWithoutAnimation
{
    [self defaultInitializerWithSideControllersLeft:YES right:NO];
    [self enterPresentationModeAndVerifyActiveStatus:YES animated:NO];
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

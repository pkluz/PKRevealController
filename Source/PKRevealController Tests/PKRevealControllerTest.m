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

#pragma mark - Helpers
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

@end
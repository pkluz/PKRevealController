//
//  UIViewController+PKRevealControllerTest.m
//  PKRevealController
//
//  Created by Nataliya Patsovska on 4/18/15.
//  Copyright (c) 2015 zuui.org (Philip Kluz). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PKRevealController.h"

@interface UIViewController_PKRevealControllerTest : XCTestCase

@end

@implementation UIViewController_PKRevealControllerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAssigningRevealController
{
    UIViewController *controller = [[UIViewController alloc] init];
    
    PKRevealController *revealController = [[PKRevealController alloc] init];
    [controller setRevealController:revealController];
    
    XCTAssertEqualObjects(controller.revealController, revealController);
}

- (void)testRetrievingRevealControllerForChildViewController
{
    UIViewController *controller = [[UIViewController alloc] init];
    [controller view];
    PKRevealController *revealController = [[PKRevealController alloc] init];
    [controller setRevealController:revealController];
    
    UIViewController *childController = [[UIViewController alloc] init];
    [controller addChildViewController:childController];

    XCTAssertNotNil(childController.parentViewController);
    XCTAssertEqualObjects(childController.revealController, revealController);
}

@end

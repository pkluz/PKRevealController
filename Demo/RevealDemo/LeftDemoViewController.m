//
//  LeftDemoViewController.m
//  PKRevealController
//
//  Created by Philip Kluz on 1/18/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import "LeftDemoViewController.h"

@implementation LeftDemoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Each view can dynamically specify the min/max width that can be revealed.
    [self.revealController setMinimumWidth:280.0f maximumWidth:324.0f forViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@ %s", [self class], __PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@ %s", [self class], __PRETTY_FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@ %s", [self class], __PRETTY_FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%@ %s", [self class], __PRETTY_FUNCTION__);
}

#pragma mark - API

- (IBAction)showOppositeView:(id)sender
{
    [self.revealController showViewController:self.revealController.rightViewController];
}

- (IBAction)togglePresentationMode:(id)sender
{
    if (![self.revealController isPresentationModeActive])
    {
        [self.revealController enterPresentationModeAnimated:YES
                                                  completion:NULL];
    }
    else
    {
        [self.revealController resignPresentationModeEntirely:NO
                                                     animated:YES
                                                   completion:NULL];
    }
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
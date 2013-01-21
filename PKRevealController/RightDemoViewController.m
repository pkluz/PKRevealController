//
//  RightDemoViewController.m
//  PKRevealController
//
//  Created by Philip Kluz on 1/18/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import "RightDemoViewController.h"
#import "PKRevealController.h"

@implementation RightDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Each view can dynamically specify the min/max width that can be revealed.
    [self.revealController setMinimumWidth:220.0f maximumWidth:244.0f forViewController:self];
}

#pragma mark - API

- (IBAction)showOppositeView:(id)sender
{
    [self.revealController showViewController:self.revealController.leftViewController];
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

/*
 * Please get familiar with iOS 6 new rotation handling as if you were to nest this controller within a UINavigationController,
 * the UINavigationController would _NOT_ relay rotation requests to his children on its own!
 */

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
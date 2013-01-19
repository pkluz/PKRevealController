//
//  LeftDemoViewController.m
//  PKRevealController
//
//  Created by Philip Kluz on 1/18/13.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import "LeftDemoViewController.h"
#import "PKRevealController.h"

@implementation LeftDemoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *toggleFrontViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toggleFrontViewButton.frame = CGRectMake(0.0f, 0.0f, 180.0f, 30.0f);
    toggleFrontViewButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    [toggleFrontViewButton setTitle:@"Toggle Front View" forState:UIControlStateNormal];
    [toggleFrontViewButton addTarget:self action:@selector(toggleFrontViewVisibility:) forControlEvents:UIControlEventTouchUpInside];
    toggleFrontViewButton.center = self.view.center;
    [self.view addSubview:toggleFrontViewButton];
}

- (void)toggleFrontViewVisibility:(id)sender
{
    if ([self.revealController isPresentationModeActive])
    {
        [self.revealController resignPresentationModeEntirely:NO
                                                     animated:YES
                                                   completion:^(void)
        {
            NSLog(@"Resigned Presentation Mode");
        }];
    }
    else
    {
        [self.revealController enterPresentationModeAnimated:YES
                                                  completion:^(void)
        {
            NSLog(@"Entered Presentation Mode");
        }];
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
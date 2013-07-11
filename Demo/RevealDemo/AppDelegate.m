//
//  AppDelegate.m
//  RevealDemo
//
//  Created by Philip Kluz on 6/27/13.
//  Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
//

#import "AppDelegate.h"

#import "FrontViewController.h"
#import "LeftDemoViewController.h"
#import "RightDemoViewController.h"

@interface AppDelegate() <PKRevealing>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Step 1: Create your controllers.
    UINavigationController *frontViewController = [[UINavigationController alloc] initWithRootViewController:[[FrontViewController alloc] init]];
    UIViewController *rightViewController = [[RightDemoViewController alloc] init];
    UIViewController *leftViewController = [[LeftDemoViewController alloc] init];
    
    // Step 2: Configure an options dictionary for the PKRevealController if necessary - in most cases the default behaviour should suffice. See PKRevealController.h for more option keys.
    /*
     NSDictionary *options = @
     {
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
     };
     */
    
    // Step 3: Instantiate your PKRevealController.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController
                                                                                options:nil];
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    
    // Step 4: Set it as your root view controller.
    self.window.rootViewController = self.revealController;
    
    [self.revealController addObserver:self
                            forKeyPath:@"state"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        NSLog(@"OBSERVER New State: %d", self.revealController.state);
    }
}

- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)state
{
    NSLog(@"DELEGATE: %s -> %d", __PRETTY_FUNCTION__, state);
}

- (void)revealController:(PKRevealController *)revealController didChangeToState:(PKRevealControllerState)state
{
    NSLog(@"DELEGATE: %s -> %d", __PRETTY_FUNCTION__, state);
}

@end

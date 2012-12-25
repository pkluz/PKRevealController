//
//  PKAppDelegate.m
//  PKRevealController
//
//  Created by Philip Kluz on 12/24/12.
//  Copyright (c) 2012 zuui.org. All rights reserved.
//

#import "PKAppDelegate.h"
#import "PKRevealController.h"

@interface PKAppDelegate()

@property (nonatomic, strong, readwrite) UIViewController *frontViewController;
@property (nonatomic, strong, readwrite) UIViewController *leftViewController;
@property (nonatomic, strong, readwrite) UIViewController *rightViewController;
@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end

@implementation PKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.frontViewController = [[UIViewController alloc] init];
    self.rightViewController = [[UIViewController alloc] init];
    self.leftViewController = [[UIViewController alloc] init];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:self.frontViewController
                                                                     leftViewController:self.leftViewController
                                                                                options:nil];
    
    self.window.rootViewController = self.revealController;
    
    self.revealController.view.backgroundColor = [UIColor redColor];
    
    self.frontViewController.view.backgroundColor = [UIColor orangeColor];
    self.leftViewController.view.backgroundColor = [UIColor greenColor];
    self.rightViewController.view.backgroundColor = [UIColor purpleColor];
    
    UIViewController *newController = [[UIViewController alloc] init];
    newController.view.backgroundColor = [UIColor blueColor];
    
    int64_t delayInSeconds = 5.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self.revealController setFrontViewController:newController animated:YES completion:^(BOOL finished)
        {
            NSLog(@"Swapped!");
        }];
    });
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
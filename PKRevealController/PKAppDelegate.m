/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKAppDelegate.h"
#import "PKRevealController.h"
#import "FrontViewController.h"
#import "LeftDemoViewController.h"
#import "RightDemoViewController.h"

#import <MapKit/MapKit.h>

@interface PKAppDelegate()

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end

@implementation PKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Step 1: Create your controllers.
    UINavigationController *frontViewController = [[UINavigationController alloc] initWithRootViewController:[[FrontViewController alloc] init]];
    UIViewController *rightViewController = [[RightDemoViewController alloc] init];
    UIViewController *leftViewController = [[LeftDemoViewController alloc] init];
    
    // Step 2: Configure an options dictionary for the PKRevealController. See PKRevealController.h for more option keys.
    NSDictionary *options = @{
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
    };
    
    // Step 3: Instantiate your PKRevealController.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController
                                                                                options:options];
    
    // Step 4: Some additional configuration to specify how much of the left view should be shown.
    CGFloat leftViewMinWidth = CGRectGetWidth(leftViewController.view.bounds)-100.0f;
    CGFloat leftViewMaxWidth = leftViewMinWidth + 20.0f;
    self.revealController.leftViewWidthRange = NSMakeRange(leftViewMinWidth, leftViewMaxWidth);
    
    // Step 5: Set it as your root view controller.
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
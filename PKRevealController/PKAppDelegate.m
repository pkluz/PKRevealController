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

@implementation PKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Step 1: Create your controllers.
    UINavigationController *frontViewController = [[UINavigationController alloc] initWithRootViewController:[[FrontViewController alloc] init]];
    UIViewController *rightViewController = [[RightDemoViewController alloc] init];
    UIViewController *leftViewController = [[LeftDemoViewController alloc] init];
    
    // Step 2: Configure an options dictionary for the PKRevealController if necessary - in most cases the default behaviour should suffice. See PKRevealController.h for more option keys.
    /*
    NSDictionary *options = @{
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
    };
    */
    
    // Step 3: Instantiate your PKRevealController.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController
                                                                                options:nil];
    
    // Step 4: Set it as your root view controller.
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];
    return YES;
    
    // Step 5: Take a look at the Left/RightDemoViewController files. They're self-sufficient as to the configuration of their reveal widths for instance.
}

@end
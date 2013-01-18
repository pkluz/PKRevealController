/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKAppDelegate.h"
#import "PKRevealController.h"
#import "PKRotationPreventionViewController.h"
#import "LeftDemoViewController.h"
#import "RightDemoViewController.h"
#import <MapKit/MapKit.h>

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
    
    self.frontViewController = [[UINavigationController alloc] initWithRootViewController:[[PKRotationPreventionViewController alloc] init]];
    self.rightViewController = [[RightDemoViewController alloc] init];
    self.leftViewController = [[LeftDemoViewController alloc] init];
    
    NSDictionary *options = @{
        PKRevealControllerAnimationDurationKey : [NSNumber numberWithFloat:0.22f],
        PKRevealControllerAnimationTypeKey : [NSNumber numberWithInteger:PKRevealControllerAnimationTypeLinear],
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerLeftViewWidthRangeKey : [NSValue valueWithRange:NSMakeRange(280.0f, 323.0f)]
    };
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:self.frontViewController
                                                                     leftViewController:self.leftViewController
                                                                    rightViewController:self.rightViewController
                                                                                options:options];
    
    self.revealController.view.backgroundColor = [UIColor blackColor];
    
    self.frontViewController.view.backgroundColor = [UIColor orangeColor];
    self.leftViewController.view.backgroundColor = [UIColor greenColor];
    self.rightViewController.view.backgroundColor = [UIColor purpleColor];
    
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
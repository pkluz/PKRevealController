/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKAppDelegate.h"
#import "PKRevealController.h"
#import "PKRotationPreventionViewController.h"

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
    self.rightViewController = [[PKRotationPreventionViewController alloc] init];
    self.leftViewController = [[UIViewController alloc] init];
    
    NSDictionary *options = @{ PKRevealControllerAnimationDurationKey : [NSNumber numberWithFloat:0.25f] };
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:self.frontViewController
                                                                     leftViewController:self.leftViewController
                                                                                options:options];
    
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
        [self.revealController setRightViewController:newController];
    });
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
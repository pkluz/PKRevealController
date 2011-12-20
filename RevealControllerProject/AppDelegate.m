/* 
 
 Copyright (c) 2011, zuui.org (Philip Kluz)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of zuui.org nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL ZUUI.ORG BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "AppDelegate.h"
#import "ZUUIRevealController.h"
#import "FrontViewController.h"
#import "RearViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		FrontViewController *frontViewController = [[FrontViewController alloc] initWithNibName:@"FrontViewController_iPhone" bundle:nil];
		RearViewController *rearViewController = [[RearViewController alloc] initWithNibName:@"RearViewController_iPhone" bundle:nil];
	    self.viewController = [[[ZUUIRevealController alloc] initWithFrontViewController:frontViewController rearViewController:rearViewController] autorelease];
	}
	else
	{
		FrontViewController *frontViewController = [[FrontViewController alloc] initWithNibName:@"FrontViewController_iPad" bundle:nil];
		RearViewController *rearViewController = [[RearViewController alloc] initWithNibName:@"RearViewController_iPad" bundle:nil];
	    self.viewController = [[[ZUUIRevealController alloc] initWithFrontViewController:frontViewController rearViewController:rearViewController] autorelease];
	}
	
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Memory management

- (void)dealloc
{
	[window release], self.window = nil;
	[viewController release], self.viewController = nil;
    [super dealloc];
}

@end

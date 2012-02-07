/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "RearViewController.h"

#import "RevealController.h"
#import "FrontViewController.h"
#import "MapViewController.h"

@interface RearViewController()

// Private Properties:

// Private Methods:

@end

@implementation RearViewController

@synthesize rearTableView = _rearTableView;

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
	}
	
	if (indexPath.row == 0)
	{
		cell.textLabel.text = @"Front View Controller";
	}
	else
	{
		cell.textLabel.text = @"Map View Controller";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RevealController *revealController = [self.parentViewController isKindOfClass:[RevealController class]] ? (RevealController *)self.parentViewController : nil;
	
	if (indexPath.row == 0)
	{
		if (![revealController.frontViewController isKindOfClass:[FrontViewController class]])
		{
			FrontViewController *frontViewController;
			
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
			{
				frontViewController = [[FrontViewController alloc] initWithNibName:@"FrontViewController_iPhone" bundle:nil];
			}
			else
			{
				frontViewController = [[FrontViewController alloc] initWithNibName:@"FrontViewController_iPad" bundle:nil];
			}
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
			[frontViewController release];
			[revealController setFrontViewController:navigationController animated:NO];
			[navigationController release];
		}
	}
	else
	{
		if (![revealController.frontViewController isKindOfClass:[MapViewController class]])
		{
			MapViewController *mapViewController;
			
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
			{
				mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController_iPhone" bundle:nil];
			}
			else
			{
				mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController_iPad" bundle:nil];
			}
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
			[mapViewController release];
			[revealController setFrontViewController:navigationController animated:NO];
			[navigationController release];
		}
	}
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Memory Management

- (void)dealloc
{
	[_rearTableView release], _rearTableView = nil;
	[super dealloc];
}

@end
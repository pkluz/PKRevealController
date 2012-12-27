/* 
 * Copyright (c) 2011, Nehira.com
 * All rights reserved.
 * 
 * @author Philip Kluz
 * @project ZUUIRevealController 0.9.5 Tutorial
 * @date 07.02.2012
 */

#import "MapViewController.h"

@implementation MapViewController

static MapViewController *shareMapViewController = nil;
+(MapViewController *)sharedController{
  @synchronized(self){
    if(shareMapViewController == nil){
      shareMapViewController = [[self alloc] init];
    }
  }
  return shareMapViewController;
}

+(id)allocWithZone:(NSZone *)zone{
  @synchronized(self){
    if (shareMapViewController == nil) {
      shareMapViewController = [super allocWithZone:zone];
      return  shareMapViewController;
    }
  }
  return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Map View", @"MapView");
	
	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
	{
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reveal", @"Reveal") style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
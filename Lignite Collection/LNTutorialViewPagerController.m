//
//  LNTutorialViewPagerController.m
//  Lignite
//
//  Created by Edwin Finch on 11/7/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import "LNTutorialViewPagerController.h"
#import "LNTutorialViewController.h"

@interface LNTutorialViewPagerController ()

@property NSArray *titleArray, *descriptionArray, *screenshotsArray, *iconsArray;

@end

@implementation LNTutorialViewPagerController

- (void)loadView {
	[super loadView];
	
	self.view = [[UIView alloc]initWithFrame:self.view.frame];
	self.view.backgroundColor = [UIColor whiteColor];
}

-(BOOL)prefersStatusBarHidden{
	return YES;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.titleArray = [[NSArray alloc]initWithObjects:
					   @"tutorial_general_list", @"tutorial_filter_view", @"tutorial_detail_view_swipe", @"tutorial_detail_actions",
					   @"tutorial_settings_screen", @"tutorial_other_actions", @"tutorial_backer_login", @"tutorial_thanks"
					   , nil];
	
	self.descriptionArray = [[NSArray alloc]initWithObjects:
					   @"tutorial_general_list_description", @"tutorial_filter_view_description", @"tutorial_detail_view_swipe_description", @"tutorial_detail_actions_description",
					   @"tutorial_settings_screen_description", @"tutorial_other_actions_description", @"tutorial_backer_login_description", @"tutorial_thanks_description"
					   , nil];
	
	self.screenshotsArray = [[NSArray alloc]initWithObjects:
							 @"tutorial_general_list.png", @"tutorial_filter_view.png", @"tutorial_detail_view_swipe.png", @"tutorial_detail_actions.png",
							 @"tutorial_settings_screen.png", @"tutorial_other_actions.png", @"tutorial_backer_login.png", @"tutorial_thanks.png"
							 , nil];
	
	self.iconsArray = [[NSArray alloc]initWithObjects:
					   @"vertical-scroll.png", @"single-tap.png", @"horizontal-scroll.png", @"single-tap.png",
					   @"vertical-scroll.png", @"single-tap.png", @"vertical-scroll.png", @"signatures_combined.png"
					   , nil];
	
	UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[LNTutorialViewPagerController class], nil];
	pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
	pageControl.currentPageIndicatorTintColor = [UIColor redColor];
	//pageControl.backgroundColor = [UIColor lightGrayColor];
	
	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	
	self.pageController.dataSource = self;
	[[self.pageController view] setFrame:[[self view] bounds]];
	
	LNTutorialViewController *initialViewController = [self viewControllerAtIndex:0];
	
	NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
	
	[self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	[self addChildViewController:self.pageController];
	[self.view addSubview:self.pageController.view];
	[self.pageController didMoveToParentViewController:self];
	
}

- (void)didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
}

- (LNTutorialViewController *)viewControllerAtIndex:(NSUInteger)index {
	
	LNTutorialViewController *childViewController = [[LNTutorialViewController alloc] init];
	childViewController.index = (int)index;
	childViewController.contentTitle = NSLocalizedString([self.titleArray objectAtIndex:index], nil);
	childViewController.contentDescription = NSLocalizedString([self.descriptionArray objectAtIndex:index], nil);
	childViewController.screenshotImage = [UIImage imageNamed:[self.screenshotsArray objectAtIndex:index]];
	childViewController.gestureImage = [UIImage imageNamed:[self.iconsArray objectAtIndex:index]];
	
	return childViewController;
	
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSUInteger index = [(LNTutorialViewController *)viewController index];
	
	if (index == 0) {
		return nil;
	}
	
	// Decrease the index by 1 to return
	index--;
	
	return [self viewControllerAtIndex:index];
	
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSUInteger index = [(LNTutorialViewController *)viewController index];
	
	index++;
	
	if (index == AMOUNT_OF_TUTORIAL_SCREENS) {
		return nil;
	}
	
	return [self viewControllerAtIndex:index];
	
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
	// The number of items reflected in the page indicator.
	return AMOUNT_OF_TUTORIAL_SCREENS;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
	// The selected item reflected in the page indicator.
	return 0;
}

@end

//
//  LNAppListController.h
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNAppInfo.h"
#import "LNDataFramework.h"
#import "LoginViewController.h"
#import "SimpleTableViewController.h"
#import "LNAppListViewController.h"

@interface LNAppListController : UIViewController <UIPageViewControllerDataSource>

/*
 LNAppListController is the UIViewController which handles paging between different LNAppListViewControllers.
 It is able to handle quick app selection and more.
 */

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSInteger currentIndex;

- (void)selectAnApp:(AppTypeCode)app;
//- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@end

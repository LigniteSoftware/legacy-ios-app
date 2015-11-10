//
//  LNAppListController.h
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPebbleApp.h"
#import "LNDataFramework.h"
#import "LoginViewController.h"
#import "SimpleTableViewController.h"
#import "LNAppListViewController.h"

@interface LNAppListController : UIViewController <UIPageViewControllerDataSource>

/*
 LNAppListController is the UIViewController which handles paging between different LNAppListViewControllers.
 It is able to handle quick app selection and more.
 */

typedef enum {
	LIGNITE_SERVICE_STATUS_DISCONNECTED = 0,
	LIGNITE_SERVICE_STATUS_WAITING_ON_CONNECTION,
	LIGNITE_SERVICE_STATUS_CONNECTED
} LigniteServiceStatus;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSInteger currentIndex;
@property LNPebbleApp *purchasingWatchapp;

- (void)reloadContentView;
- (void)selectAnApp:(WatchApp)app;
- (void)purchaseApp:(LNPebbleApp*)watchApp;
- (void)restorePurchases;
+ (BOOL)userOwnsApp:(LNPebbleApp*)pebbleApp;
- (void)askTutorialQuestion;

@end

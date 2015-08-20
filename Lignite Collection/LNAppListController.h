//
//  LNAppListController.h
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNAppListController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

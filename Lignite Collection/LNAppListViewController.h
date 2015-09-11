//
//  LNAppListViewController.h
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNAppInfo.h"
#import "LNAppListController.h"

@interface LNAppListViewController : UIViewController

@property IBOutlet UILabel *label;

@property AppTypeCode currentType;
@property UIPageViewController *sourcePageViewController;
@property UIViewController *sourceViewController;

@property UIImageView *imageView, *leftArrow, *rightArrow;
@property UILabel *appTitleLabel, *nextButton, *previousButton;
@property UITextView *appDescriptionLabel;
@property UIButton *installButton, *settingsButton, *editButton;
@property BOOL owns_app;

- (void)updatePebblePreview;
- (void)updateContentBasedOnType;
- (IBAction)actionButtonPushed:(id)sender;
- (IBAction)logoutButtonPushed:(id)sender;
- (IBAction)tutorialEnd:(id)sender;

@end

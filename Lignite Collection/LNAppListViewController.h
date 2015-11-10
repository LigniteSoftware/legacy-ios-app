//
//  LNAppListViewController.h
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import "LNPebbleApp.h"

@interface LNAppListViewController : UIViewController

@property IBOutlet UILabel *label;

@property LNPebbleApp *watchApp;
@property UIPageViewController *sourcePageViewController;
@property UIViewController *sourceViewController;
@property PBWatch *connectedWatch;

@property UIImageView *imageView, *leftArrow, *rightArrow;
@property UILabel *appTitleLabel, *nextButton, *previousButton;
@property UITextView *appDescriptionLabel;
@property UIButton *installButton, *settingsButton, *editButton;
@property BOOL owns_app;

- (void)updatePebblePreview;
- (void)updateContentBasedOnType;
- (IBAction)logoutButtonPushed:(id)sender;

@end

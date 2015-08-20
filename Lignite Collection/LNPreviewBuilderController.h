//
//  LNPreviewBuilderController.h
//  Lignite
//
//  Created by Edwin Finch on 8/16/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNAppListViewController.h"
#import "LNAppInfo.h"

@interface LNPreviewBuilderController : UIViewController

@property IBOutlet UILabel *pebbleLabel, *screenshotLabel;
@property IBOutlet UIButton *pebbleNextButton, *pebblePreviousButton, *screenshotNextButton, *screenshotPreviousButton, *defaultButton;
@property IBOutlet UIImageView *pebbleView, *screenshotView;

@property LNAppListViewController *sourceController;
@property AppTypeCode appType;

enum PebbleModel {
    PEBBLE_MODEL_NOT_FOUND = -1,
    PEBBLE_MODEL_BIANCA_BLACK = 0,
    PEBBLE_MODEL_BIANCA_SILVER,
    PEBBLE_MODEL_BOBBY_BLACK,
    PEBBLE_MODEL_BOBBY_GOLD,
    PEBBLE_MODEL_BOBBY_SILVER,
    PEBBLE_MODEL_SNOWY_BLACK,
    PEBBLE_MODEL_SNOWY_RED,
    PEBBLE_MODEL_SNOWY_WHITE,
    PEBBLE_MODEL_TINTIN_BLACK,
    PEBBLE_MODEL_TINTIN_RED,
    PEBBLE_MODEL_TINTIN_WHITE
};

+ (NSArray*)pebbleModelArray;
+ (UIImage*)imageForPebble:(UIImage*)pebble andScreenshot:(UIImage*)screenshot;

@end

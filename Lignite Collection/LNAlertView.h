//
//  LNAlertView.h
//  Lignite
//
//  Created by Edwin Finch on 8/30/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNAppInfo.h"

@interface LNAlertView : UIAlertView

/*
 LNAlertView keeps track of extra items, such as the settings dictionary that may not have
 gone through.
 */

@property NSDictionary *dictionary;
@property BOOL isGuard;
@property NSError *error;
@property AppTypeCode app;

@end

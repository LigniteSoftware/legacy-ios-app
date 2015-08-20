//
//  LNColourPicker.h
//  Lignite
//
//  Created by Edwin Finch on 8/17/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNLabel.h"
#import "LNAppInfo.h"

@interface LNColourPicker : UIViewController

@property LNLabel *sourceLabel;
@property AppTypeCode appType;
@property NSString *loadColour;

- (void)setCurrentColour:(NSString*)current;

@end

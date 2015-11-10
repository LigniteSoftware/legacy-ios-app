//
//  LNColourPicker.h
//  Lignite
//
//  Created by Edwin Finch on 8/17/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNLabel.h"
#import "LNPebbleApp.h"

@interface LNColourPicker : UIViewController

@property LNLabel *sourceLabel;
@property LNPebbleApp *watchApp;
@property NSString *loadColour;

- (void)setCurrentColour:(NSString*)current;

@end

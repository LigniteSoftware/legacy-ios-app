//
//  LNPebblePickerViewController.h
//  Lignite
//
//  Created by Edwin Finch on 11/7/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNAppListController.h"

@interface LNPebbleViewController : UIViewController

@property LNAppListController *sourceListController;
@property BOOL askTutorialQuestionAfter;

@end

//
//  LNSettingsViewController.h
//  
//
//  Created by Edwin Finch on 2015-07-31.
//
//

#import <UIKit/UIKit.h>
#import "LNPebbleApp.h"

@interface LNSettingsViewController : UITableViewController <UIAlertViewDelegate>

#define LIGNITE_SETTINGS nil

- (id)initWithStyle:(UITableViewStyle)style forWatchApp:(LNPebbleApp*)watchApp;
- (void)setAsAlertSettings;

@end

//
//  LNSettingsViewController.h
//  
//
//  Created by Edwin Finch on 2015-07-31.
//
//

#import <UIKit/UIKit.h>
#import "LNAppInfo.h"

@interface LNSettingsViewController : UITableViewController <UIAlertViewDelegate>

- (void)setAsAlertSettings;
- (void)setPebbleApp:(AppTypeCode)app;

@end

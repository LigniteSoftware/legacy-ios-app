//
//  SettingsViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-19.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PebbleInfo.h"

@interface SpeedometerSettingsViewController : UITableViewController

@property AppTypeCode appType;
@property IBOutlet UISwitch *invertSwitch, *btDisAlertSwitch, *btReAlertSwitch, *bootAnimationSwitch, *btIconSwitch, *ditheringSwitch;
@property IBOutlet UILabel *outerLabel, *middleLabel, *innerLabel;

@end

//
//  ChunkyViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-30.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChunkyTableViewController : UITableViewController

@property IBOutlet UISwitch *btdisalertSwitch, *btrealertSwitch, *invertSwitch, *showBatteryBarSwitch;
@property IBOutlet UILabel *minuteColourLabel, *hourColourLabel, *backgroundColourLabel;

@end

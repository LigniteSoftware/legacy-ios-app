//
//  LinesTableViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-06-01.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinesTableViewController : UITableViewController

@property IBOutlet UILabel *timeColourLabel, *dateColourLabel, *backgroundColourLabel;
@property IBOutlet UISwitch *btdisalertSwitch, *btrealertSwitch, *showDateSwitch, *altDateFormatSwitch;

@end

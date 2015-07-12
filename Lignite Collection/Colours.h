//
//  ColoursTableViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-06-01.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColoursTableViewController : UITableViewController

@property IBOutlet UISwitch *btdisalertSwitch, *btrealertSwitch, *organizeSwitch, *randomizeSwitch;
@property IBOutlet UISlider *barWidthSlider;
@property IBOutlet UILabel *minuteColourLabel, *hourColourLabel, *barWidthValueLabel;

@end

//
//  TreeOfColoursTableViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-06-25.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreeOfColoursTableViewController : UITableViewController

@property IBOutlet UILabel *defaultWidthLabel, *custColour1Label, *custColour2Label, *custColour3Label, *circleColourLabel, *timeColourLabel;
@property IBOutlet UISwitch *btdisalertSwitch, *btrealertSwitch, *randomizeSwitch;
@property IBOutlet UISlider *defaultWidthSlider;

@end

//
//  PulseTableViewController.h
//  
//
//  Created by Edwin Finch on 2015-07-09.
//
//

#import <UIKit/UIKit.h>

@interface PulseTableViewController : UITableViewController

@property IBOutlet UISwitch *btdisalertSwitch, *btrealertSwitch, *invertSwitch, *shakeToAnimateSwitch, *constAnimSwitch;
@property IBOutlet UILabel *circleColourLabel, *backgroundColourLabel;

@end

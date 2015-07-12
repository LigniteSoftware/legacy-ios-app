//
//  TimezonesTableTableViewController.h
//  
//
//  Created by Edwin Finch on 2015-07-08.
//
//

#import <UIKit/UIKit.h>

@interface TimezonesTableTableViewController : UITableViewController

@property IBOutlet UISwitch *btdisalert, *btrealert, *analogue_circles_1, *subtract_hour, *analogue_circles_2;
@property IBOutlet UILabel *colour1, *colour2, *timezones_label;
@property IBOutlet UITextField *name_1, *name_2;

@end

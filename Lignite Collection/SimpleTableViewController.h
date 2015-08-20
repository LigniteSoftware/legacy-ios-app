#import <UIKit/UIKit.h>
#import "LNLabel.h"

@protocol SimpleTableViewControllerDelegate <NSObject>

@required
- (void)itemSelectedatRow:(NSInteger)row;

@end

@interface SimpleTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) LNLabel *source_label;
@property (assign, nonatomic) id<SimpleTableViewControllerDelegate> delegate;

@end
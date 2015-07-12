#import <UIKit/UIKit.h>

@protocol SimpleTableViewControllerDelegate <NSObject>

@required
- (void)itemSelectedatRow:(NSInteger)row;

@end

@interface SimpleTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *tableData;
@property (assign, nonatomic) id<SimpleTableViewControllerDelegate> delegate;

@end
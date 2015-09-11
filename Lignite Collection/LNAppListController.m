//
//  LNAppListController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListController.h"

@interface LNAppListController () <SimpleTableViewControllerDelegate>

@property NSURLConnection *verifyConnection;

@end

@implementation LNAppListController

BOOL controller_owns_app[APP_COUNT];

- (void)pushed:(id)sender{
    LNAppListViewController *controller = (LNAppListViewController*)[[self.pageViewController viewControllers] objectAtIndex:0];
    [controller actionButtonPushed:self];
}

- (void)topLeftPushed:(id)sender {
    LNAppListViewController *controller = (LNAppListViewController*)[[self.pageViewController viewControllers] objectAtIndex:0];
    [controller logoutButtonPushed:self];
}

- (void)fireBigList:(UISwipeGestureRecognizer*)recognizer{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    
    NSArray *array = [LNAppInfo  nameArray];
    NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
    for(int i = 0; i < [array count]; i++){
        [fixedArray insertObject:[[array objectAtIndex:i] capitalizedString] atIndex:i];
    }
    
    tableViewController.tableData = fixedArray;
    tableViewController.navigationItem.title = NSLocalizedString(@"pick_an_app", nil);
    tableViewController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void)itemSelectedatRow:(NSInteger)row {
    self.currentIndex = row;
    [self selectAnApp:(AppTypeCode)self.currentIndex];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if(connection == self.verifyConnection){
        if(![status isEqual:@200]){
            [LNDataFramework setUserLoggedIn:[LNDataFramework getUsername] :NO];
            LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            [self presentViewController:loginScreen animated:YES completion:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"illegal_account", "user's account is malformed")
                                                            message:NSLocalizedString(@"illegal_account_description", "ditto, description")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"damn_okay", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            //Good2go
            //G2G
            //GG
            for(int i = 0; i < APP_COUNT; i++){
                controller_owns_app[i] = YES;
                LNAppListViewController *controller = (LNAppListViewController*)[[self.pageViewController viewControllers]objectAtIndex:0];
                controller.owns_app = YES;
                [controller updateContentBasedOnType];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    LNAppListViewController *startingViewController = [self viewControllerAtIndex:[LNDataFramework getPreviousAppType]];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+50);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(pushed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"logout", nil) style:UIBarButtonItemStylePlain target:self action:@selector(topLeftPushed:)];
    self.title = @"Lignite";
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fireBigList:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:recognizer];
    
    if([LNDataFramework isUserBacker]){
        NSString *post = [NSString stringWithFormat:@"username=%@&accessToken=%@", [LNDataFramework getUsername], [LNDataFramework getUserToken]];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/checkaccesstoken/index.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        self.verifyConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [self.verifyConnection start];
    }
    
    if(![LNDataFramework isUserBacker]){
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"restore", nil);
    }
	/*
	for (UIScrollView *view in self.pageViewController.view.subviews) {
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			
			view.scrollEnabled = NO;
		}
	}
	 */ 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source


- (void)selectAnApp:(AppTypeCode)app { 
	// Instead get the view controller of the first page
	LNAppListViewController *newInitialViewController = (LNAppListViewController *)[self viewControllerAtIndex:app];
	NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
	// Do the setViewControllers: again but this time use direction animation:
	[self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}
/*
- (void)selectAnApp:(AppTypeCode)app {
    LNAppListViewController *startingViewController = [self viewControllerAtIndex:app];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    self.currentIndex = app;
    [self.pageViewController didMoveToParentViewController:self];
}
*/
- (LNAppListViewController *)viewControllerAtIndex:(NSUInteger)index{
    // Create a new view controller and pass suitable data.
    LNAppListViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AppViewController"];
    pageContentViewController.currentType = (AppTypeCode)index;
    pageContentViewController.owns_app = controller_owns_app[index];
	pageContentViewController.sourcePageViewController = self.pageViewController;
	pageContentViewController.sourceViewController = self;
    //pageContentViewController.sourceController = self;
    self.currentIndex = index;
    
    [LNDataFramework setPreviousAppType:(AppTypeCode)index];
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return APP_COUNT;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((LNAppListViewController*) viewController).currentType;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((LNAppListViewController*) viewController).currentType;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index > APP_COUNT-1) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

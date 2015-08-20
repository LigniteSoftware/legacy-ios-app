//
//  LNAppListController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListController.h"
#import "LNAppListViewController.h"
#import "LNAppInfo.h"
#import "LNCommunicationLayer.h"
#import "LoginViewController.h"

@interface LNAppListController ()

@property NSInteger currentIndex;
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if(connection == self.verifyConnection){
        if(![status isEqual:@200]){
            [DataFramework setUserLoggedIn:[DataFramework getUsername] :NO];
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
    
    LNAppListViewController *startingViewController = [self viewControllerAtIndex:[DataFramework getPreviousAppType]];
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
    
    if([DataFramework isUserBacker]){
        NSString *post = [NSString stringWithFormat:@"username=%@&accessToken=%@", [DataFramework getUsername], [DataFramework getUserToken]];
        
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
    
    if(![DataFramework isUserBacker]){
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"restore", nil);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (void)selectAnApp:(AppTypeCode)app {
    LNAppListViewController *startingViewController = [self viewControllerAtIndex:app];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    self.currentIndex = app;
}

- (LNAppListViewController *)viewControllerAtIndex:(NSUInteger)index{
    // Create a new view controller and pass suitable data.
    LNAppListViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AppViewController"];
    pageContentViewController.currentType = (AppTypeCode)index;
    pageContentViewController.owns_app = controller_owns_app[index];
    self.currentIndex = index;
    
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
    [DataFramework setPreviousAppType:(AppTypeCode)index];
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
    [DataFramework setPreviousAppType:(AppTypeCode)index];
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

//
//  LNAppListViewController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListViewController.h"
#import <PebbleKit/PebbleKit.h>
#import <StoreKit/StoreKit.h>
#import "NSUserDefaults+MPSecureUserDefaults.h"
#import "LoginViewController.h"
#import "LNAppInfo.h"
#import "UIView+Toast.h"
#import "LNCommunicationLayer.h"
#import "CreditsViewController.h"
#import "FeedbackViewController.h"
#import "LNSettingsViewController.h"
#import "LNPreviewBuilderController.h"
#import "LNColourPicker.h"
#import "SimpleTableViewController.h"

@interface LNAppListViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver, SimpleTableViewControllerDelegate>

@property UIButton *button;
@property (strong) UIDocumentInteractionController *uidocumentInteractionController;
@property NSArray* appArray;
@property NSData *response1;
@property UITapGestureRecognizer *imageTapRecognizer;
@property BOOL usingTimeImage;
@property NSURLConnection *logoutConnection, *verifyConnection;

@end

@implementation LNAppListViewController

//#define SKIP_PURCHASE

- (void)purchaseApp {
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:[[PebbleInfo skuArray] objectAtIndex:self.currentType]]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cant_pay_title", "can't make payments, probs parental controls")
                                                        message:NSLocalizedString(@"cant_pay_description", "ditto, description")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"damn_okay", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)purchase:(SKProduct *)product{
    [self.view makeToast:NSLocalizedString(@"please_wait", nil)];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    unsigned long count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored: %@", transaction.payment.productIdentifier);
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
    if(queue.transactions.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"restored_purchases", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"restored_purchases_description", nil), (int)queue.transactions.count]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"okay_thanks", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)itemPurchased:(SKPaymentTransaction*)transaction {
    NSLog(@"Transaction state -> Purchased/Restored: %@", transaction.payment.productIdentifier);
    int index = (int)[[PebbleInfo skuArray] indexOfObject:transaction.payment.productIdentifier];
    self.owns_app = true;
    if(index == self.currentType){
        [self.settingsButton setTitle:NSLocalizedString(@"settings", nil) forState:UIControlStateNormal];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecureBool:YES forKey:[NSString stringWithFormat:@"owns-%@", [PebbleInfo getAppNameFromType:index]]];
    [defaults synchronize];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        NSLog(@"transaction state: %d", (int)transaction.transactionState);
        switch((int)transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"Got transaction %@! Restoring...", transaction);
                [self itemPurchased:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (IBAction)installApp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"pebble://appstore/%@", [[PebbleInfo locationArray] objectAtIndex:self.currentType]]]];
    /*
     * RIP in pepperoni 1.2.1 feature u will b missed <3 ;(((
     *
     NSURL *pbwUrl = [[NSBundle mainBundle] URLForResource:[PebbleInfo getAppNameFromType:self.currentType] withExtension:@"pbw"];
     self.uidocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:pbwUrl];
     self.uidocumentInteractionController.UTI = @"com.getpebble.bundle.watchface";
     self.uidocumentInteractionController.delegate = self;
     
     // presentOptionsMenu works all the time
     //[self.uidocumentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
     
     // presentOpenInMenu is better (only shows compatible apps) but only works
     // if the Pebble app is installed (so not in the simulator)
     [self.uidocumentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
     */
}

- (IBAction)logoutButtonPushed:(id)sender {
    if([DataFramework isUserBacker]){
        [self.view makeToast:NSLocalizedString(@"logging_out", "logging the user out...")];
        
        
        NSString *post = [NSString stringWithFormat:@"username=%@&currentDevice=%@&accessToken=%@", [DataFramework getUsername], [DataFramework getCurrentDevice], [DataFramework getUserToken]];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/logout/index.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        self.logoutConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [self.logoutConnection start];
    }
    else{
        [self.view makeToast:NSLocalizedString(@"restoring_purchases", "for restoring purchases")];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (IBAction)actionButtonPushed:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *logoutAction;
    if([DataFramework isUserBacker]){
        logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"send_feedback", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FEEDBACK"];
            [self showViewController:controller sender:nil];
        }];
    }
    else{
        logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"kickstarter_backer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            //[self showViewController:controller sender:nil];
            [DataFramework setUserBacker:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }];
    }
    UIAlertAction *creditsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"credits", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        CreditsViewController *creditsController = [self.storyboard instantiateViewControllerWithIdentifier:@"CREDITS"];
        [self showViewController:creditsController sender:nil];
    }];
    UIAlertAction *tutorialAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"replay_tutorial", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSLog(@"tutorial");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:creditsAction];
    [controller addAction:logoutAction];
    [controller addAction:tutorialAction];
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = self.view;
    controller.popoverPresentationController.sourceRect = CGRectMake(800, 50, 1.0, 1.0);
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)settingsButtonPushed:(id)sender {
    if(!self.owns_app){
        [self purchaseApp];
        return;
    }
    NSString *appUUID = [PebbleInfo getAppUUID:self.currentType];
    [DataFramework sendLigniteGuardUnlockToPebble:self.currentType];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    PBWatch *watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [watch appMessagesLaunch:nil withUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [view_controller setPebbleApp:self.currentType];
    [self showViewController:view_controller sender:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection == self.logoutConnection){
        NSLog(@"Error %@", [error localizedDescription]);
        NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"failed_to_logout", nil), [error localizedDescription]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                        message:failedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if(connection == self.logoutConnection){
        if([status isEqual:@200] || [status isEqual:@404]){
            [DataFramework setUserLoggedIn:[DataFramework getUsername] :NO];
            LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            [self presentViewController:loginScreen animated:YES completion:nil];
        }
        else{
            NSString *localizedError = [jsonResult objectForKey:@"localized_message"];
            NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"failed_to_logout", nil), localizedError];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                            message:failedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(0 == buttonIndex){ //cancel button
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else if (1 == buttonIndex){
        FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
        [DataFramework setUserBacker:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)fireBigList:(UISwipeGestureRecognizer*)recognizer{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    
    NSArray *array = [PebbleInfo  nameArray];
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
    self.currentType = (AppTypeCode)row;
    [self updateContentBasedOnType];
    [DataFramework setPreviousAppType:self.currentType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect viewFrame = self.view.frame;
    
    self.appTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (viewFrame.size.height/4)*2.3, viewFrame.size.width, 40)];
    self.appTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0f];
    self.appTitleLabel.text = @"App Title";
    self.appTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.appTitleLabel];
    
    self.installButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 - 54, viewFrame.size.height - 66, 52, 52)];
    [self.installButton setImage:[UIImage imageNamed:@"install-button.png"] forState:UIControlStateNormal];
    [self.installButton addTarget:self action:@selector(installApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.installButton];
    
    self.settingsButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 + 6, viewFrame.size.height - 66, 52, 52)];
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
    
    self.appDescriptionLabel = [[UITextView alloc]initWithFrame:CGRectMake(10, (viewFrame.size.height/4)*2.6, viewFrame.size.width-20, (viewFrame.size.height - 70) - (viewFrame.size.height/4)*2.6 - 10)];
    self.appDescriptionLabel.editable = NO;
    self.appDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.appDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    [self.view addSubview:self.appDescriptionLabel];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 80, viewFrame.size.width, (viewFrame.size.height/4)*2.3 - 80)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    [NSUserDefaults setSecret:@"XqcOyp_yl2U"];
    
    if([DataFramework getUsername].length != 6){
        [DataFramework setUserBacker:NO];
    }
    
    if(![DataFramework isUserBacker]){
        for(int i = 0; i < APP_COUNT; i++){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            BOOL valid = NO;
            BOOL registered = [defaults secureBoolForKey:[NSString stringWithFormat:@"owns-%@", [PebbleInfo getAppNameFromType:i]] valid:&valid];
            if (!valid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tampered_with", nil)
                                                                message:NSLocalizedString(@"tampered_with_description", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"freeloader", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                self.owns_app = registered;
            }
        }
    }
    
#ifdef SKIP_PURCHASE
    if(![DataFramework isUserLoggedIn]){
        for(int i = 0; i < APP_COUNT; i++){
            owns_app[i] = true;
            NSLog(@"Skipping purchases... You own everything. Congrats!");
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PURCHASES SKIPPED"
                                                        message:@"Let's not repeat the actions of August 7th... Remember to turn this off. Sorry for this Philipp"
                                                       delegate:nil
                                              cancelButtonTitle:@"Fuck that shit, thanks"
                                              otherButtonTitles:nil];
        [alert show];
    }
#endif
        
    self.imageTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageGestureRecognizer:)];
    
    [self.imageView addGestureRecognizer:self.imageTapRecognizer];
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:@"key-ANSWERED"];
    
    if(!result){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hello_there", nil)
                                                        message:NSLocalizedString(@"are_you_a_backer", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"no", nil)
                                              otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
        [alert show];
        [DataFramework userAnsweredBackerQuestion:YES];
    }
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fireBigList:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:recognizer];
    
    /*
     LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
     [view_controller setPebbleApp:APP_TYPE_SPEEDOMETER];
     [self showViewController:view_controller sender:self];
     
     LNColourPicker *colour_picker = [[LNColourPicker alloc]init];
     [self showViewController:colour_picker sender:self];
     
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPushed:)];
    self.navigationController.title = @"Lignite";
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Hello" style:UIBarButtonItemStyleDone target:self action:@selector(actionButtonPushed:)];
    */
    [self updateContentBasedOnType];
    UIImageView *testView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [testView setImage:[UIImage imageNamed:@"tutorial.png"]];
    
    UILabel *logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -30, 150, 300)];
    logoutLabel.text = NSLocalizedString(@"tutorial_logout", nil);
    logoutLabel.numberOfLines = 0;
    logoutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    logoutLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0f];
    [testView addSubview:logoutLabel];
    
    UILabel *swipeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 300)];
    swipeLabel.text = NSLocalizedString(@"tutorial_swipe", nil);
    swipeLabel.numberOfLines = 0;
    swipeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    swipeLabel.textAlignment = NSTextAlignmentCenter;
    swipeLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0f];
    [testView addSubview:swipeLabel];
    
    UILabel *actionLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, -10, 120, 300)];
    actionLabel.text = NSLocalizedString(@"tutorial_action", nil);
    actionLabel.numberOfLines = 0;
    actionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    actionLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0f];
    [testView addSubview:actionLabel];
    
    UILabel *installLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 300, 150, 300)];
    installLabel.text = NSLocalizedString(@"tutorial_install", nil);
    installLabel.numberOfLines = 0;
    installLabel.lineBreakMode = NSLineBreakByWordWrapping;
    installLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0f];
    [testView addSubview:installLabel];
    
    UILabel *settingsLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 290, 140, 300)];
    settingsLabel.text = NSLocalizedString(@"tutorial_purchase", nil);
    settingsLabel.numberOfLines = 0;
    settingsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    settingsLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0f];
    [testView addSubview:settingsLabel];

    //[self.view addSubview:testView];
}

- (void)updatePebblePreview {
    UIImage *toImage = [LNPreviewBuilderController imageForPebble:[UIImage imageNamed:[DataFramework defaultPebbleImage]] andScreenshot:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", [PebbleInfo getAppNameFromType:self.currentType], [DataFramework pebbleImageIsTime:[DataFramework defaultPebbleImage]] ? @"basalt" : @"aplite"]]];
    self.imageView.image = toImage;
}

- (void)tapImageGestureRecognizer:(UITapGestureRecognizer*)rec {
    LNPreviewBuilderController *editController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditController"];
    editController.appType = self.currentType;
    [self showViewController:editController sender:self];
    editController.sourceController = self;
}

- (IBAction)fireTimer:(id)sender {
    NSLog(@"Response of %@", self.response1);
}

- (void)updateContentBasedOnType {
    self.appTitleLabel.text = [[PebbleInfo getAppNameFromType:self.currentType] capitalizedString];
    [self updatePebblePreview];
    self.appDescriptionLabel.text = [PebbleInfo getAppDescriptionFromType:self.currentType];
    if(self.currentType == APP_TYPE_KNIGHTRIDER){
        self.appTitleLabel.text = @"RightNighter";
    }
    self.appDescriptionLabel.font = [UIFont fontWithName:@"helvetica neue" size:14.0];
    self.settingsButton.enabled = [PebbleInfo settingsEnabled:self.currentType];
    if(!self.owns_app){
        [self.settingsButton setImage:[UIImage imageNamed:@"purchase-button.png"] forState:UIControlStateNormal];
    }
    else{
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
    }
}
/*
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"currentType"]) {
        [self updateContentBasedOnType];
    }
}
*/
- (void)swipeRight {
    self.usingTimeImage = YES;
    
    UIView *theParentView = [self.view superview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [theParentView addSubview:self.view];
    if((self.currentType-1) < 0){
        self.currentType = APP_COUNT-1;
    }
    else{
        self.currentType--;
    }
    
    [[theParentView layer] addAnimation:animation forKey:@"showSecondViewController"];
    
    [DataFramework setPreviousAppType:self.currentType];
}

- (void)swipeLeft {
    self.usingTimeImage = YES;
    
    UIView *theParentView = [self.view superview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [theParentView addSubview:self.view];
    if((self.currentType+1) > APP_COUNT-1){
        self.currentType = 0;
    }
    else{
        self.currentType++;
    }
    
    [[theParentView layer] addAnimation:animation forKey:@"showSecondViewController"];
    
    [DataFramework setPreviousAppType:self.currentType];
}

- (IBAction)leftButtonPush:(id)sender {
    [self swipeRight];
}

- (IBAction)rightButtonPush:(id)sender {
    [self swipeLeft];
}

- (void)swipeRightRecognizer:(UIGestureRecognizer*)rec {
    [self swipeRight];
}

- (void)swipeLeftRecognizer:(UIGestureRecognizer*)rec {
    [self swipeLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

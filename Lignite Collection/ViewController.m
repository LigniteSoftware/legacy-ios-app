//
//  ViewController.m
//  Lignite Collection
//
//  Created by Edwin Finch on 2015-05-02.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <PebbleKit/PebbleKit.h>
#import <StoreKit/StoreKit.h>
#import "NSUserDefaults+MPSecureUserDefaults.h"

#import "ViewController.h"
#import "LoginViewController.h"
#import "Speedometer.h"
#import "PebbleInfo.h"
#import "UIView+Toast.h"
#import "DataFramework.h"
#import "Knightrider.h"
#import "Chunky.h"
#import "Colours.h"
#import "Lines.h"
#import "CreditsViewController.h"
#import "FeedbackViewController.h"

@interface ViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property UIButton *button;
@property (strong) UIDocumentInteractionController *uidocumentInteractionController;
@property NSArray* appArray;
@property NSData *response1;
@property UITapGestureRecognizer *imageTapRecognizer;
@property AppTypeCode currentType;
@property BOOL usingTimeImage;
@property NSURLConnection *logoutConnection, *verifyConnection;

@end

@implementation ViewController

bool owns_app[APP_COUNT];

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
    }
}

- (IBAction)purchase:(SKProduct *)product{
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restored Purchases"
                                                        message:[NSString stringWithFormat:@"All of your previous %d purchases have been restored. Thanks a lot for your support!", (int)queue.transactions.count]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay, thanks!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)itemPurchased:(SKPaymentTransaction*)transaction {
    NSLog(@"Transaction state -> Purchased/Restored: %@", transaction.payment.productIdentifier);
    int index = (int)[[PebbleInfo skuArray] indexOfObject:transaction.payment.productIdentifier];
    owns_app[index] = true;
    if(index == self.currentType){
        [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
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
        [self.view makeToast:@"Logging you out..."];
        
        
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
        [self.view makeToast:@"Restoring purchases..."];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (IBAction)actionButtonPushed:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *logoutAction;
    if([DataFramework isUserBacker]){
        logoutAction = [UIAlertAction actionWithTitle:@"Send Feedback" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FEEDBACK"];
            [self showViewController:controller sender:nil];
        }];
    }
    else{
        logoutAction = [UIAlertAction actionWithTitle:@"Backer?" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            //[self showViewController:controller sender:nil];
            [DataFramework setUserBacker:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }];
    }
    UIAlertAction *creditsAction = [UIAlertAction actionWithTitle:@"Credits" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSLog(@"Pushing credits");
        CreditsViewController *creditsController = [self.storyboard instantiateViewControllerWithIdentifier:@"CREDITS"];
        [self showViewController:creditsController sender:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:creditsAction];
    [controller addAction:logoutAction];
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = self.view;
    controller.popoverPresentationController.sourceRect = CGRectMake(800, 50, 1.0, 1.0);
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)settingsButtonPushed:(id)sender {
    if(!owns_app[self.currentType]){
        [self purchaseApp];
        return;
    }
    ViewController *controller;
    switch(self.currentType){
        case APP_TYPE_SPEEDOMETER:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Speedometer"];
            break;
        case APP_TYPE_KNIGHTRIDER:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Knightrider"];
            break;
        case APP_TYPE_CHUNKY:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Chunky"];
            break;
        case APP_TYPE_COLOURS:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Colours"];
            break;
        case APP_TYPE_LINES:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Lines"];
            break;
        case APP_TYPE_TREE_OF_COLOURS:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-TreeOfColours"];
            break;
        case APP_TYPE_TIMEZONES:;
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Timezones"];
            break;
        case APP_TYPE_SLOT_MACHINE:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-SlotMachine"];
            break;
        case APP_TYPE_PULSE:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGS-Pulse"];
            break;
        default:
            break;
    }
    [self showViewController:controller sender:self];
    NSLog(@"getting uuid");
    NSString *appUUID = [PebbleInfo getAppUUID:self.currentType];
    NSLog(@"got uuid");
    [DataFramework sendLigniteGuardUnlockToPebble:self.currentType];
    NSLog(@"setting uuid");
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    NSLog(@"getting bytes");
    
    PBWatch *watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [watch appMessagesLaunch:nil withUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    NSLog(@"getting watch");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection == self.logoutConnection){
        NSLog(@"Error %@", [error localizedDescription]);
        NSString *failedDescription = [[NSString alloc]initWithFormat:@"Failed to log you out, sorry! Error: %@", [error localizedDescription]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                        message:failedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
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
            NSString *failedDescription = [[NSString alloc]initWithFormat:@"Your logout response failed for some weird reason. Feel free to try again. Error: %@", localizedError];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                            message:failedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else if(connection == self.verifyConnection){
        if(![status isEqual:@200]){
            [DataFramework setUserLoggedIn:[DataFramework getUsername] :NO];
            LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            [self presentViewController:loginScreen animated:YES completion:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Illegal Account"
                                                            message:@"You're illegally logged in. Potentially because your account was reset with the account resetter. You've now been forced to logout! Enjoy."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Damn, okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            //Good2go
            //G2G
            //GG
            for(int i = 0; i < APP_COUNT; i++){
                owns_app[i] = true;
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSUserDefaults setSecret:@"XqcOyp_yl2U"];
    
    if([DataFramework getUsername].length != 6){
        [DataFramework setUserBacker:NO];
    }
    
    for(int i = 0; i < APP_COUNT; i++){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        BOOL valid = NO;
        BOOL registered = [defaults secureBoolForKey:[NSString stringWithFormat:@"owns-%@", [PebbleInfo getAppNameFromType:i]] valid:&valid];
        if (!valid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tampered With"
                                                            message:@"Who do you think you are, 1337 leet haxor? You clearly tampered with NSUserDefaults to try and get free apps. Why not just pay a dollar and help me out?"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Sure, I'm a no good freeloader but I'll pay the price!"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            owns_app[i] = registered;
        }
    }
    owns_app[APP_TYPE_KNIGHTRIDER] = true;
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]init];
    [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [rightRecognizer addTarget:self action:@selector(swipeRightRecognizer:)];
    [self.view addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc]init];
    [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftRecognizer addTarget:self action:@selector(swipeLeftRecognizer:)];
    [self.view addGestureRecognizer:leftRecognizer];
    
    self.imageTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageGestureRecognizer:)];
    
    [self.imageView addGestureRecognizer:self.imageTapRecognizer];
    
    [self addObserver:self forKeyPath:@"currentType" options:NSKeyValueObservingOptionNew context:nil];
    
    self.currentType = APP_TYPE_SPEEDOMETER;
    [self tapImageGestureRecognizer:nil];
    
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
        self.navigationItem.leftBarButtonItem.title = @"Restore";
    }

}

- (void)tapImageGestureRecognizer:(UITapGestureRecognizer*)rec {
    self.usingTimeImage = !self.usingTimeImage;
    UIImage *toImage;
    if(self.usingTimeImage){
        NSString *newImageName = [[NSString alloc] initWithFormat:@"%@_time.png", [PebbleInfo getAppNameFromType:self.currentType]];
        toImage = [UIImage imageNamed:newImageName];
    }
    else{
        NSString *newImageName = [[NSString alloc] initWithFormat:@"%@_tintin.png", [PebbleInfo getAppNameFromType:self.currentType]];
        toImage = [UIImage imageNamed:newImageName];
    }
    [UIView transitionWithView:self.imageView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
}

- (IBAction)fireTimer:(id)sender {
    NSLog(@"Response of %@", self.response1);
}

- (void)updateContentBasedOnType {
    self.appTitleLabel.text = [[PebbleInfo getAppNameFromType:self.currentType] capitalizedString];
    NSString *imageName = [[NSString alloc]initWithFormat:@"%@_%@.png", [PebbleInfo getAppNameFromType:self.currentType], @"time"];
    self.imageView.image = [UIImage imageNamed:imageName];
    self.appDescriptionLabel.text = [PebbleInfo getAppDescriptionFromType:self.currentType];
    if(self.currentType == APP_TYPE_KNIGHTRIDER){
        self.appTitleLabel.text = @"RightNighter";
    }
    self.appDescriptionLabel.font = [UIFont fontWithName:@"helvetica neue" size:14.0];
    self.settingsButton.enabled = [PebbleInfo settingsEnabled:self.currentType];
    if(!owns_app[self.currentType]){
        [self.settingsButton setTitle:@"Purchase" forState:UIControlStateNormal];
    }
    else{
        [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"currentType"]) {
        [self updateContentBasedOnType];
    }
}

- (void)swipeRightRecognizer:(UIGestureRecognizer*)rec {
    self.usingTimeImage = YES;

    UIView *theParentView = [self.view superview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
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
}

- (void)swipeLeftRecognizer:(UIGestureRecognizer*)rec {
    self.usingTimeImage = YES;

    UIView *theParentView = [self.view superview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 * Dust
 *
- (IBAction)weatherRequest:(id)sender {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"api.openweathermap.org/data/2.5/weather?q=Guelph, CA"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    self.response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                      target:self
                                                    selector:@selector(fireTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
    
}
*/
@end


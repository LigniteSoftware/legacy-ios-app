//
//  LoginViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LoginViewController.h"
#import "LNCommunicationLayer.h"
#import "UIView+Toast.h"
#import "LNAppListViewController.h"

@interface LoginViewController ()

@property NSURLConnection *loginConnection, *userDataConnection;

@end

@implementation LoginViewController

- (IBAction)checkcodeButtonHit:(id)sender {
    NSLog(@"Got username of %@ and password of %@", self.usernameTextField.text, self.passwordTextField.text);
    
    [DataFramework setUsername:self.passwordTextField.text];
    
    NSString *post = [NSString stringWithFormat:@"email=%@&password=%@&currentDevice=%@", self.usernameTextField.text, self.passwordTextField.text, [DataFramework getCurrentDevice]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/login/ios/index.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    self.loginConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [self.loginConnection start];
}

- (void)resetCodeLinkHit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lignite.me/reset/"]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error %@", [error localizedDescription]);
    NSString *failedDescription = [[NSString alloc]initWithFormat:@"Your request failed to even send, sorry! Error: %@", [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                    message:failedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if([connection isEqual:self.loginConnection]){
        NSError *error;
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSNumber *status = [jsonResult objectForKey:@"status"];
        NSLog(@"Got login result of %@", jsonResult);
        if([status isEqual:@200]){
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *requestURL = [[NSString alloc]initWithFormat:@"https://api.lignite.me/v2/backer/get_info_with_code.php?username=%@", [DataFramework getUsername]];
            [request setURL:[NSURL URLWithString:requestURL]];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            self.userDataConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [self.userDataConnection start];
            
            [DataFramework setUserToken:[jsonResult objectForKey:@"token"]];
        }
        else{
            if([status isEqual:@401]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:@"Nice try. Someone is already logged in to this account. If you are the owner of this account, you can reset your account for access by clicking the link below and following the instructions on our external website."];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Now, now..."
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if([status isEqual:@404]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:@"No Lignite accounts were found with this username and password, sorry! Make sure it's perfectly typed. Please avoid copy-pasting. (Error 404)"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, silly goose!"
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                NSString *localizedMessage = [jsonResult objectForKey:@"localized_message"];
                NSString *failedDescription = [[NSString alloc]initWithFormat:@"Not sure how to handle this one: %@", localizedMessage];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Well, that's embarassing."
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else{
        NSError *error = nil;
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(error){
            NSLog(@"Error parsing user data: %@", [error localizedDescription]);
        }
        
        NSLog(@"Got user data %@", object);
        NSString *name = @"my friend";
        if([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = object;
            name = [results objectForKey:@"name"];
            NSLog(@"Got name: %@", name);
            [DataFramework setUserData:results];
            [DataFramework setUserLoggedIn:[DataFramework getUsername] :YES];
            /* proceed with results as you like; the assignment to
             an explicit NSDictionary * is artificial step to get
             compile-time checking f9rom here on down (and better autocompletion
             when editing). You could have just made object an NSDictionary *
             in the first place but stylistically you might prefer to keep
             the question of type open until it's confirmed */
        }
        else{
            /* there's no guarantee that the outermost object in a JSON
             packet will be a dictionary; if we get here then it wasn't,
             so 'object' shouldn't be treated as an NSDictionary; probably
             you need to report a suitable error condition */
            NSLog(@"Error with kind of class");
        }
        
        self.checkcodeButton.enabled = false;
        self.accessButton.enabled = true;
        self.descriptionLabel.text = [[NSString alloc]initWithFormat:@"Welcome %@!", name];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    NSLog(@"Finished, boi");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [self textFieldShouldReturn:self.passwordTextField];
    [self textFieldShouldReturn:self.usernameTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.checkcodeButton setTitle:NSLocalizedString(@"check", "check code") forState:UIControlStateNormal];
    [self.accessButton setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    self.usernameTextField.placeholder = NSLocalizedString(@"username", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"password", nil);
    self.resetLabel.text = NSLocalizedString(@"cant_login", @"for resetting account");
    [self.noAccountButton setTitle:NSLocalizedString(@"no_account", "for non backers") forState:UIControlStateNormal];
    
    if([DataFramework isUserLoggedIn]){
        NSDictionary *userData = [DataFramework getUserData];
        if(!userData){
            NSLog(@"User data is nil! Returning...");
            self.descriptionLabel.text = @"Weird issue parsing your data :/";
            return;
        }
        NSLog(@"Got %@", userData);
        NSString *name = [userData objectForKey:@"name"];
        NSString *email = [DataFramework getEmail];
        NSString *password = [DataFramework getUsername];
        self.checkcodeButton.enabled = false;
        self.accessButton.enabled = true;
        self.usernameTextField.text = email;
        self.passwordTextField.text = password;
        self.descriptionLabel.text = [[NSString alloc]initWithFormat:NSLocalizedString(@"welcome_back", "welcome back %@"), name];
        self.usernameTextField.enabled = NO;
        self.passwordTextField.enabled = NO;
    }
    UITapGestureRecognizer *resetGestureRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetCodeLinkHit)];
    [self.resetLabel addGestureRecognizer:resetGestureRec];
    
    UITapGestureRecognizer *keyboardGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
    [self.view addGestureRecognizer:keyboardGestureRecognizer];
    
    /*
    UITapGestureRecognizer *gaveUpGestureRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gaveUpLinkHit)];
    [self.gaveUpLabel addGestureRecognizer:gaveUpGestureRec];
     */
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 6;
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

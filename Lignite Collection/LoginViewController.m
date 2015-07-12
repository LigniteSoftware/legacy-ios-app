//
//  LoginViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LoginViewController.h"
#import "DataFramework.h"
#import "UIView+Toast.h"
#import "ViewController.h"

@interface LoginViewController ()

@property NSURLConnection *loginConnection, *userDataConnection;

@end

@implementation LoginViewController

- (IBAction)checkcodeButtonHit:(id)sender {
    if(self.accessCodeTextField.text.length < 6){
        self.descriptionLabel.text = @"Code must be 6 characters.";
        return;
    }
    NSLog(@"Got value of %@", self.accessCodeTextField.text);
    
    [DataFramework setUsername:self.accessCodeTextField.text];
    
    NSString *post = [NSString stringWithFormat:@"username=%@&currentDevice=%@", self.accessCodeTextField.text, [DataFramework getCurrentDevice]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/login/index.php"]];
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
        if([status isEqual:@200]){
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *requestURL = [[NSString alloc]initWithFormat:@"https://api.lignite.me/v2/backer/get_info_with_code.php?username=%@", self.accessCodeTextField.text];
            [request setURL:[NSURL URLWithString:requestURL]];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            self.userDataConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [self.userDataConnection start];
            
            [DataFramework setUserToken:[jsonResult objectForKey:@"token"]];
        }
        else{
            if([status isEqual:@401]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:@"Nice try. Someone is already logged in with this access code. If you are the owner of this access code, log out of your previous device or email contact@edwinfinch.com to recover it. (Error 401)"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Now, now..."
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if([status isEqual:@404]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:@"No Kickstarter backer was found with this access code, sorry! Make sure it's perfectly typed. Please avoid copy-pasting. (Error 404)"];
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
        
        NSString *name = @"my friend";
        if([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = object;
            name = [results objectForKey:@"name"];
            NSLog(@"Got name: %@", name);
            [DataFramework setUserData:results];
            [DataFramework setUserLoggedIn:[DataFramework getUsername] :YES];
            /* proceed with results as you like; the assignment to
             an explicit NSDictionary * is artificial step to get
             compile-time checking from here on down (and better autocompletion
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.accessCodeTextField setDelegate:self];
    if([DataFramework isUserLoggedIn]){
        NSDictionary *userData = [DataFramework getUserData];
        if(!userData){
            NSLog(@"User data is nil! Returning...");
            self.descriptionLabel.text = @"Weird issue parsing your data :/";
            return;
        }
        NSString *name = [userData objectForKey:@"name"];
        NSString *accessCode = [DataFramework getUsername];
        self.checkcodeButton.enabled = false;
        self.accessButton.enabled = true;
        self.accessCodeTextField.text = accessCode;
        self.descriptionLabel.text = [[NSString alloc]initWithFormat:@"Welcome back, %@.", name];
        self.accessCodeTextField.enabled = NO;
    }
    UITapGestureRecognizer *resetGestureRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetCodeLinkHit)];
    [self.resetLabel addGestureRecognizer:resetGestureRec];
    
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

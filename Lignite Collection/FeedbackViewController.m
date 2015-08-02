//
//  FeedbackViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "FeedbackViewController.h"
#import "LNCommunicationLayer.h"
#import "UIView+Toast.h"

@interface FeedbackViewController ()

@property NSArray *whatTypeData;

@end

@implementation FeedbackViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [self textFieldShouldReturn:self.detailsValueTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.howImportantValueSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self textFieldShouldReturn:self.detailsValueTextField];
    self.detailsValueTextField.delegate = self;
    
    UITapGestureRecognizer *keyboardGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
    [self.view addGestureRecognizer:keyboardGestureRecognizer];
    
    self.whatTypeData = [NSArray arrayWithObjects:@"Crash", @"Bug", @"Design-related", @"Feature-related", @"Other", nil];
    self.whatTypeValuePicker.delegate = self;
    self.whatTypeValuePicker.dataSource = self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.whatTypeData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.whatTypeData[row];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.howImportantValueLabel.text = [NSString stringWithFormat:@"%d", (int)floor(sender.value)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender {
    NSString *post = [NSString stringWithFormat:@"username=%@&currentDevice=%@&accessToken=%@&type=%@&details=%@&importance=%d", [DataFramework getUsername], [DataFramework getCurrentDevice], [DataFramework getUserToken], self.whatTypeData[[self.whatTypeValuePicker selectedRowInComponent:0]], self.detailsValueTextField.text, (int)floor(self.howImportantValueSlider.value)];

    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/feedback/index.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [self.view makeToast:@"Sending..." duration:0.7f position:nil];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error %@", [error localizedDescription]);
    NSString *failedDescription = [[NSString alloc]initWithFormat:@"Your feedback failed to even send, sorry! Error: %@", [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                    message:failedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if([status isEqual:@200]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"Your feedback hit the server successfully. Thanks! Feel free to post more feedback, or go back to the main screen."
                                                       delegate:nil
                                              cancelButtonTitle:@"Awesome"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        NSString *localizedError = [jsonResult objectForKey:@"localized_message"];
        NSString *failedDescription = [[NSString alloc]initWithFormat:@"Your feedback failed to hit the server. Response: %@. Feel free to try again.", localizedError];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                        message:failedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    NSLog(@"Finished, boi");
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

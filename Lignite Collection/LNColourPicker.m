//
//  LNColourPicker.m
//  Lignite
//
//  Created by Edwin Finch on 8/17/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNColourPicker.h"
#import "LNDataFramework.h"
#import "LNLabel.h"
#import "LNAppInfo.h"
#import "LNAlertView.h"

@interface LNColourPicker () <UIAlertViewDelegate>

@property NSDictionary *colours, *colours_corrected;
@property UILabel *selectedLabel;
@property LNLabel *currentLabel;
@property UIColor *selectedColour;
@property NSMutableArray *colourLabels;
@property NSArray *allkeys;
@property UISegmentedControl *segmentedControl;

@end

@implementation LNColourPicker

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button index %ld called", (long)buttonIndex);
    LNAlertView *alert = (LNAlertView*)alertView;
    
    if(0 == buttonIndex){ //cancel button
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else if (1 == buttonIndex){
        LNSettingsViewController *failSettings = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [failSettings setAsAlertSettings];
        [self showViewController:failSettings sender:self];
        
    }
    else if(buttonIndex == 2){
        [LNDataFramework sendDictionaryToPebble:alert.dictionary forApp:alert.app withSettingsController:self];
    }
}

- (void)colourLabelTapped:(UITapGestureRecognizer*)recognizer {
    LNLabel *label = (LNLabel*)[recognizer view];
    self.selectedColour = label.backgroundColor;
    self.selectedLabel.backgroundColor = self.selectedColour;
    self.selectedLabel.layer.borderColor = self.selectedColour.CGColor;
    self.selectedLabel.text = NSLocalizedString([[[self.colours objectForKey:[[label.json_object objectForKey:@"hex_value"] uppercaseString]] objectForKey:@"closest"] objectForKey:@"name"], nil);
    
    if([self.colourLabels indexOfObject:label] > 59){
        self.selectedLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        self.selectedLabel.textColor = [UIColor whiteColor];
    }
	
	NSLog(@"label %p", label);
    
    CGRect getRect = self.view.frame;
    int i = (int)[self.colourLabels indexOfObject:self.currentLabel];
    int i1 = (int)[self.colourLabels indexOfObject:label];
    int vertDifference = (getRect.size.height-80-(((getRect.size.height/12)*8)+getRect.size.width/12))/6;
    [UIView animateWithDuration:0.2 animations:^{
        self.currentLabel.frame = CGRectMake((i % 8)*getRect.size.width/8 + getRect.size.width/12/2/2, ((i/8)*getRect.size.height/12) + 114 + vertDifference, getRect.size.width/12, getRect.size.width/12);
        
        label.frame = CGRectMake((i1 % 8)*getRect.size.width/8 + getRect.size.width/12/2/2 - 4, ((i1/8)*getRect.size.height/12) + 114 + vertDifference - 4, getRect.size.width/12 + 8, getRect.size.width/12 + 8);
        
        self.currentLabel = label;
		
		NSLog(@"label1 %p", label);
    }];
	
    LNLabel *sourceLabel = self.sourceLabel;
	NSLog(@"label2 %p", sourceLabel);
    [LNDataFramework sendStringToPebble:[[label.json_object objectForKey:@"hex_value"] substringFromIndex:1] pebbleKey:[[sourceLabel.json_object objectForKey:@"pebble_key"] integerValue] storageKey:[sourceLabel.json_object objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.appType] fromController:self];
    self.sourceLabel.backgroundColor = self.currentLabel.backgroundColor;
}

- (void)setCurrentColour:(NSString*)current {
    current = [NSString stringWithFormat:@"#%@", current];

    NSUInteger index = [self.allkeys indexOfObject:current];

    BOOL corrected = NO;
    if(index > 63){
        self.segmentedControl.selectedSegmentIndex = 1;
        [self segmentedControlChanged:self.segmentedControl];
        corrected = YES;
    }
    index = [self.allkeys indexOfObject:corrected ? [current lowercaseString] : current];
    if(index > 63){
        return;
    }
    if([self.colourLabels count] < 1){
        NSLog(@"No labels in array... returning.");
        return;
    }
    LNLabel *sourceLabel = [self.colourLabels objectAtIndex:index];
    UIColor *colour = [LNDataFramework colorFromHexString:[current substringFromIndex:1]];
    self.selectedColour = colour;
    sourceLabel.backgroundColor = colour;
    self.selectedLabel.backgroundColor = colour;
    self.selectedLabel.layer.borderColor = self.selectedColour.CGColor;
    
    self.selectedLabel.text = NSLocalizedString([[[self.colours objectForKey:[current uppercaseString]] objectForKey:@"closest"] objectForKey:@"name"], nil);
    
    if([self.colourLabels indexOfObject:sourceLabel] > 59){
        self.selectedLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        self.selectedLabel.textColor = [UIColor whiteColor];
    }
    
    self.currentLabel = sourceLabel;
    
    CGRect getRect = self.view.frame;
    int i = (int)[self.colourLabels indexOfObject:self.currentLabel];
    int vertDifference = (getRect.size.height-80-(((getRect.size.height/12)*8)+getRect.size.width/12))/6;
    [UIView animateWithDuration:0.2 animations:^{
        self.currentLabel.frame = CGRectMake((i % 8)*getRect.size.width/8 + getRect.size.width/12/2/2 - 4, ((i/8)*getRect.size.height/12) + 114 + vertDifference - 4, getRect.size.width/12 + 8, getRect.size.width/12 + 8);
    }];

}

- (IBAction)segmentedControlChanged:(UISegmentedControl*)segment {
    if(segment.selectedSegmentIndex == 0){
        self.allkeys = [self.colours allKeys];
    }
    else{
        self.allkeys = [self.colours_corrected allKeys];
    }
    self.allkeys = [self.allkeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    BOOL corrected = segment.selectedSegmentIndex == 0;
    
    for(int i = 0; i < [self.allkeys count]; i++){
        UIColor *colour = [LNDataFramework colorFromHexString:[[[self.allkeys objectAtIndex:i] substringFromIndex:1] lowercaseString]];
        if(corrected){
            NSString *string = [self.colours_corrected objectForKey:[[self.allkeys objectAtIndex:i] lowercaseString]];
            colour = [LNDataFramework colorFromHexString:[string substringFromIndex:1]];
        }
        LNLabel *label = [self.colourLabels objectAtIndex:i];
        label.layer.borderColor = colour.CGColor;
        if(i == 63){
            label.layer.borderColor = [UIColor blackColor].CGColor;
        }
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.cornerRadius = 3.0;
        label.backgroundColor = colour;
        
        //label.text = [NSString stringWithFormat:@"%d", i];
    }
    self.selectedLabel.backgroundColor = self.currentLabel.backgroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"colour_picker", nil)];
    
    NSData *colourData = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colours_uncorrected" ofType:@"json"]];
    NSError *colourError;
    self.colours = [NSJSONSerialization JSONObjectWithData:colourData options:NSJSONReadingMutableContainers error:&colourError];
    
    NSData *correctedColourData = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colours_corrected" ofType:@"json"]];
    NSError *correctedColourError;
    self.colours_corrected = [NSJSONSerialization JSONObjectWithData:correctedColourData options:NSJSONReadingMutableContainers error:&correctedColourError];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.colourLabels = [[NSMutableArray alloc]init];
    
    self.allkeys = [self.colours allKeys];
    self.allkeys = [self.allkeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    CGRect getRect = [self.view frame];
    int vertDifference = 0;
    for(int i = 0; i < [self.allkeys count]; i++){
        UIColor *colour = [LNDataFramework colorFromHexString:[[self.allkeys objectAtIndex:i] substringFromIndex:1]];
        vertDifference = (getRect.size.height-80-(((getRect.size.height/12)*8)+getRect.size.width/12))/6;
        LNLabel *label = [[LNLabel alloc]initWithFrame:CGRectMake((i % 8)*getRect.size.width/8 + getRect.size.width/12/2/2, ((i/8)*getRect.size.height/12) + 114 + vertDifference, getRect.size.width/12, getRect.size.width/12)];
        label.layer.borderColor = colour.CGColor;
        if(i == 63){
            label.layer.borderColor = [UIColor blackColor].CGColor;
        }
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.cornerRadius = 3.0;
        label.backgroundColor = colour;
        //label.text = [NSString stringWithFormat:@"%d", i];
        
        UITapGestureRecognizer *tap_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colourLabelTapped:)];
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:tap_recognizer];
        
        label.json_object = [[NSDictionary alloc]initWithObjects:@[[self.allkeys objectAtIndex:i]] forKeys:@[@"hex_value"]];
		NSLog(@"%@", [[self.colours objectForKey:[self.allkeys objectAtIndex:i]] objectForKey:@"name"]);
        [self.view addSubview:label];
        [self.colourLabels addObject:label];
    }
    UILabel *selectedTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, getRect.size.height-80, getRect.size.width-40, 30)];
    selectedTitle.textAlignment = NSTextAlignmentCenter;
    selectedTitle.text = NSLocalizedString(@"selected_colour", nil);
    selectedTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    NSLog(@"%f", getRect.size.height);
    if(getRect.size.height > 480){
        [self.view addSubview:selectedTitle];
    }
    
    self.selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, getRect.size.height-50, getRect.size.width-40, 40)];
    self.selectedLabel.layer.borderColor = [UIColor redColor].CGColor;
    self.selectedLabel.layer.masksToBounds = YES;
    self.selectedLabel.layer.borderWidth = 1.0;
    self.selectedLabel.layer.cornerRadius = 8.0;
    self.selectedLabel.backgroundColor = [UIColor redColor];
    self.selectedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    self.selectedLabel.textAlignment = NSTextAlignmentCenter;
    self.selectedLabel.textColor = [UIColor whiteColor];
    self.selectedLabel.text = @"Red";
    [self.view addSubview:self.selectedLabel];
    
    NSArray *itemArray = [NSArray arrayWithObjects: NSLocalizedString(@"corrected", nil), NSLocalizedString(@"uncorrected", nil), nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    int difference = ((0/8)*getRect.size.height/12) + 114 + vertDifference - 74;
    self.segmentedControl.frame = CGRectMake((getRect.size.width-250)/2, 70 + difference/6, 250, 30);
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents: UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 1;
    [self.view addSubview:self.segmentedControl];
    
    if(self.loadColour){
        [self setCurrentColour:self.loadColour];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"got memory warning mate");
}

@end

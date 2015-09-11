//
//  CreditsViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-31.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "CreditsViewController.h"

@interface CreditsViewController ()

@end

@implementation CreditsViewController

//Setup credits and internatioalize
- (void)viewDidLoad {
    [super viewDidLoad];
    self.creditsView.text = NSLocalizedString(@"full_credits", nil);
    self.creditsView.textColor = [UIColor whiteColor];
	self.creditsView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
	[self.creditsView scrollRangeToVisible:NSMakeRange(0, 0)];
	self.title = NSLocalizedString(@"credits", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

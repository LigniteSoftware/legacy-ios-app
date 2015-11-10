//
//  LNPebblePickerViewController.m
//  Lignite
//
//  Created by Edwin Finch on 11/7/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import "LNPebbleViewController.h"
#import "LNPreviewBuilder.h"
#import "LNPebbleWatch.h"

@interface LNPebbleViewController ()

@property UILabel *titleView, *subtitleView, *selectedView;
@property UIScrollView *contentView;
@property NSMutableArray *imageLayerArray;
@property UIButton *cancelButton, *applyButton;
@property int currentlySelectedWatch;
// 666 ≥ 666
@end

@implementation LNPebbleViewController

- (void)loadView {
	[super loadView];
	
	self.view = [[UIView alloc]initWithFrame:self.view.frame];
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.title = NSLocalizedString(@"pick_a_pebble", nil);
}

- (void)dismissPebblePicker {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyWasTapped {
	[LNPreviewBuilder setDefaultPebbleWatch:[[LNPebbleWatch alloc] initWithModelIndex:self.currentlySelectedWatch]];
	[self.sourceListController reloadContentView];
	[self dismissPebblePicker];
	if(self.askTutorialQuestionAfter){
		[self.sourceListController askTutorialQuestion];
	}
}

- (void)pebbleWasTapped:(UIGestureRecognizer*)recognizer {
	UIImageView *view = (UIImageView*)recognizer.view;
	[UIView animateWithDuration:0.5 animations:^{
		view.layer.borderWidth = 1;
		view.layer.borderColor = [UIColor redColor].CGColor;
		view.layer.cornerRadius = 3;
	}];
	int indexOfWatch = 0;
	for(UIImageView *imageView in self.imageLayerArray){
		if(view != imageView){
			imageView.layer.borderWidth = 0;
			imageView.layer.borderColor = [UIColor clearColor].CGColor;
		}
		else{
			self.currentlySelectedWatch = indexOfWatch;
			self.selectedView.text = [[LNPebbleWatch alloc]initWithModelIndex:self.currentlySelectedWatch].localizedModelName;
		}
		indexOfWatch++;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect frame = self.view.frame;
	
	self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, frame.size.width, 30)];
	self.titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0f];
	self.titleView.text = NSLocalizedString(@"choose_your_pebble_title", nil);
	self.titleView.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:self.titleView];
	
	self.subtitleView = [[UILabel alloc]initWithFrame:CGRectMake(0, self.titleView.frame.origin.y+self.titleView.frame.size.height+6, frame.size.width, 30)];
	self.subtitleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
	self.subtitleView.text = NSLocalizedString(@"choose_your_pebble_description", nil);
	self.subtitleView.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:self.subtitleView];
	
	self.contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.subtitleView.frame.origin.y+self.subtitleView.frame.size.height+10, frame.size.width, frame.size.height-(self.subtitleView.frame.origin.y+self.subtitleView.frame.size.height + 10 + 100))];
	[self.view addSubview:self.contentView];
	
	self.imageLayerArray = [[NSMutableArray alloc]init];
	
	int spacing = 15;
	int factor = 2;
	int height = self.view.frame.size.height/3;
	for(int i = 0; i < PEBBLE_MODEL_MAXIMUM; i++){
		LNPebbleWatch *pebbleWatch = [[LNPebbleWatch alloc]initWithModelIndex:i];
		
		UIImageView *pebbleView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/factor * (i % factor) + 10, (i/factor) * (height+spacing), self.view.frame.size.width/factor - 20, height)];
		pebbleView.contentMode = UIViewContentModeScaleAspectFit;
		
		UIImage *screenshot = [UIImage imageNamed:[NSString stringWithFormat:@"lignite_logo_%@.png", pebbleWatch.platformName]];
		
		CGSize size = pebbleWatch.modelImage.size;
		UIGraphicsBeginImageContext(size);
		[pebbleWatch.modelImage drawInRect:CGRectMake(0, 0, size.width,size.height)];
		if(pebbleWatch.isRoundDisplay){
			[screenshot drawInRect:CGRectMake(72, 158, 180, 180)];
		}
		else{
			[screenshot drawInRect:CGRectMake(65, 126, 144, 168)];
		}
		UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		pebbleView.image = finalImage;

		
		UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pebbleWasTapped:)];
		pebbleView.userInteractionEnabled = YES;
		[pebbleView addGestureRecognizer:recognizer];
		[self.contentView addSubview:pebbleView];
		[self.imageLayerArray addObject:pebbleView];
	}
	UIImageView *lastObject = [self.contentView.subviews lastObject];
	[self.contentView setContentSize:CGSizeMake(self.contentView.frame.size.width, lastObject.frame.origin.y + lastObject.frame.size.height + 10)];
	
	UIImageView *currentlySelectedPebbleView = (UIImageView*)[self.imageLayerArray objectAtIndex:[LNPreviewBuilder defaultPebbleWatch]];
	currentlySelectedPebbleView.layer.borderWidth = 1;
	currentlySelectedPebbleView.layer.borderColor = [UIColor redColor].CGColor;
	currentlySelectedPebbleView.layer.cornerRadius = 3;
	
	self.selectedView = [[UILabel alloc]initWithFrame:CGRectMake(10, self.contentView.frame.origin.y+self.contentView.frame.size.height+14, self.view.frame.size.width-20, 20)];
	self.selectedView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
	self.selectedView.text = [LNPreviewBuilder defaultPebble].localizedModelName;
	self.selectedView.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:self.selectedView];
	
	self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(30, self.selectedView.frame.origin.y+self.selectedView.frame.size.height+14, self.view.frame.size.width/2 - 60, 30)];
	self.cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
	self.cancelButton.backgroundColor = [UIColor redColor];
	self.cancelButton.layer.masksToBounds = YES;
	self.cancelButton.layer.cornerRadius = 3.0f;
	[self.cancelButton addTarget:self action:@selector(dismissPebblePicker) forControlEvents:UIControlEventTouchUpInside];
	[self.cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
	[self.view addSubview:self.cancelButton];
	
	self.applyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 + 30, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height)];
	self.applyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
	self.applyButton.backgroundColor = [UIColor redColor];
	self.applyButton.layer.masksToBounds = YES;
	self.applyButton.layer.cornerRadius = 3.0f;
	[self.applyButton addTarget:self action:@selector(applyWasTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.applyButton setTitle:NSLocalizedString(@"apply", nil) forState:UIControlStateNormal];
	[self.view addSubview:self.applyButton];
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

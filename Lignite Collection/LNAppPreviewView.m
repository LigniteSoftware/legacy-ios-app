//
//  LNAppPreviewView.m
//  Lignite
//
//  Created by Edwin Finch on 10/16/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import "LNAppPreviewView.h"
#import "LNPreviewBuilder.h"
#import "LNAppListController.h"
#import "LNPebbleApp.h"

@interface LNAppPreviewView()

@property UIImageView *imageView;
@property UILabel *titleView;
@property LNPebbleApp *pebbleApp;

@end

@implementation LNAppPreviewView

- (void)previewViewTapGestureListener {
	if(!self.delegate){
		NSLog(@"Delegate is nil, sorry bud. Refusing click request for app %d.", self.pebbleApp.watchApp);
		return;
	}
	[self.delegate appPreviewTileClickedOnApp:self.pebbleApp.watchApp];
}

- (id)initWithWatchApp:(LNPebbleApp*)pebbleApp onFrame:(CGRect)frame {
	self = [super init];
	if(self){
		self.pebbleApp = pebbleApp;
		self.frame = frame;
		
		LNPebbleWatch *pebbleWatch = [LNPreviewBuilder defaultPebble];

		UIImage *image = [LNPreviewBuilder imageForPebble:pebbleWatch andScreenshot:[LNPreviewBuilder screenshotForPebble:pebbleWatch forWatchApp:pebbleApp atIndex:1] markAsPurchased:[LNAppListController userOwnsApp:self.pebbleApp]]; //update the image
		//UIImage *image = [LNPreviewBuilderController screenshotForPebble:@"snowy" appType:app index:1];
		self.imageView = [[UIImageView alloc]initWithImage:image];
		self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/4 * 3);
		//self.imageView.backgroundColor = [UIColor blueColor];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.imageView];
		
		int titleViewOriginY = self.frame.size.height/4 * 3;
		self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, titleViewOriginY, self.frame.size.width, self.frame.size.height-titleViewOriginY)];
		self.titleView.text = self.pebbleApp.localizedName;
		self.titleView.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
		self.titleView.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.titleView];
		
		[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewViewTapGestureListener)]];
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

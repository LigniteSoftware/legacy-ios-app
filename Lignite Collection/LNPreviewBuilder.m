//
//  LNPreviewBuilderController.m
//  Lignite
//
//  Created by Edwin Finch on 8/16/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNPreviewBuilder.h"
#import "LNDataFramework.h"
#import "LNPebbleWatch.h"

@interface LNPreviewBuilder ()

@end

@implementation LNPreviewBuilder

+ (LNPebbleWatch*)defaultPebble {
	return [[LNPebbleWatch alloc]initWithModelIndex:(int)[LNPreviewBuilder defaultPebbleWatch]];
}

+ (NSInteger)defaultPebbleWatch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:@"defaultPebble"];
}

+ (void)setDefaultPebbleWatch:(LNPebbleWatch*)pebble {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:pebble.model forKey:@"defaultPebble"];
	[defaults synchronize];
}

+ (UIImage*)imageForPebble:(LNPebbleWatch*)pebbleWatch andScreenshot:(UIImage*)screenshot markAsPurchased:(BOOL)purchased {
	CGSize size = pebbleWatch.modelImage.size;
    UIGraphicsBeginImageContext(size);
	
    [pebbleWatch.modelImage drawInRect:CGRectMake(0, 0, size.width,size.height)];
	
	if(pebbleWatch.isRoundDisplay){
		[screenshot drawInRect:CGRectMake(72, 159, 180, 180)];
	}
	else{
		[screenshot drawInRect:CGRectMake(65, 126, 144, 168)];
	}
	
	if(purchased){
		UIImage *checkmarkImage = [UIImage imageNamed:@"purchased_checkmark.png"];
		[checkmarkImage drawInRect:CGRectMake(size.width-80, size.height-100, 80, 80)];
	}
	
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage*)screenshotForPebble:(LNPebbleWatch*)pebbleWatch forWatchApp:(LNPebbleApp*)watchApp atIndex:(int)index {
    UIImage *image;
	
    NSString *imageName = [NSString stringWithFormat:@"%@-%@-%d.png", watchApp.appName, pebbleWatch.platformName, index];
    image = [UIImage imageNamed:imageName];
    
    return image;
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

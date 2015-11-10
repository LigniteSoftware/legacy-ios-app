//
//  LNAppPreviewView.h
//  Lignite
//
//  Created by Edwin Finch on 10/16/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPebbleApp.h"

@protocol LNAppPreviewViewClickDelegate <NSObject>

- (void)appPreviewTileClickedOnApp:(WatchApp)app;

@end

@interface LNAppPreviewView : UIView

@property (nonatomic, assign) id <LNAppPreviewViewClickDelegate> delegate;

- (id)initWithWatchApp:(LNPebbleApp*)pebbleApp onFrame:(CGRect)frame;

@end
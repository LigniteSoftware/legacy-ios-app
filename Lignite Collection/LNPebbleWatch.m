//
//  LNPebbleWatch.m
//  Lignite
//
//  Created by Edwin Finch on 11/6/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import "LNPebbleWatch.h"

@implementation LNPebbleWatch

- (id)initWithModelIndex:(int)index {
	self = [super init];
	if(self){
		self.model = index;
		self.platform = [LNPebbleWatch pebblePlatformFromWatchModel:self.model];
		self.isBlackAndWhite = (self.platform == PEBBLE_PLATFORM_APLITE);
		self.isRoundDisplay = (self.platform == PEBBLE_PLATFORM_CHALK);
		if(self.platform != PEBBLE_PLATFORM_NOT_FOUND){
			self.platformName = [LNPebbleWatch platformNameFromPlatform:self.platform];
		}
		if(self.model != PEBBLE_MODEL_NOT_FOUND){
			self.modelImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [LNPebbleWatch pebbleModelNameFromModel:self.model]]];
			NSString *modelName = [LNPebbleWatch pebbleModelNameFromModel:self.model];
			self.modelName = modelName;
			self.localizedModelName = NSLocalizedString(modelName, nil);
		}
	}
	return self;
}

+ (NSString*)platformNameFromPlatform:(enum PebblePlatform)platform {
	return [[[NSArray alloc] initWithObjects:@"aplite", @"basalt", @"chalk", nil] objectAtIndex:platform];
}

+ (NSString*)pebbleModelNameFromModel:(enum PebbleModel)model {
	return [[[NSArray alloc]initWithObjects:
			 @"bianca-black", @"bianca-silver",
			 @"tintin-black", @"tintin-red", @"tintin-white",
			 @"bobby-black", @"bobby-gold", @"bobby-silver",
			 @"snowy-black", @"snowy-red", @"snowy-white",
			 @"chalk-20mm-silver", @"chalk-20mm-black",
			 @"chalk-14mm-silver", @"chalk-14mm-rose-gold", @"chalk-14mm-black",
			 nil] objectAtIndex:model];
}

+ (enum PebblePlatform)pebblePlatformFromWatchModel:(enum PebbleModel)pebbleModel {
	enum PebblePlatform result = PEBBLE_PLATFORM_NOT_FOUND;
	if(pebbleModel > PEBBLE_MODEL_NOT_FOUND && pebbleModel < PEBBLE_MODEL_BOBBY_BLACK){
		result = PEBBLE_PLATFORM_APLITE;
	}
	else if(pebbleModel > PEBBLE_MODEL_TINTIN_WHITE && pebbleModel < PEBBLE_MODEL_SPALDING_20MM_SILVER){
		result = PEBBLE_PLATFORM_BASALT;
	}
	else if(pebbleModel > PEBBLE_MODEL_SNOWY_WHITE){
		result = PEBBLE_PLATFORM_CHALK;
	}
	return result;
}

@end

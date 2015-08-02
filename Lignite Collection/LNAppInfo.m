//
//  PebbleInfo.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-17.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppInfo.h"

@implementation PebbleInfo

NSArray *settingsCount;

/*
 { 3049, 9569 },
 { 5672, 1932 },
 { 3498, 1030 }
 */

+ (NSInteger)uuidEndingKeyForIndex:(AppTypeCode)code {
    NSInteger array[] = {
        1098, 1035, 3012, 7856, 3242, 0000, 7865, 3049, 5672, 3498
    };
    return array[code];
}

+ (NSInteger)unlockTokenKeyForIndex:(AppTypeCode)code {
    NSInteger array[] = {
        546, 535, 392, 545, 2334, 0000, 6345, 9569, 1932, 1030
    };
    return array[code];
}

+ (NSArray*)skuArray {
    return [[NSArray alloc]initWithObjects:@"ind_face_speedometer", @"ind_face_knightrider", @"ind_face_chunky", @"ind_face_lines", @"ind_face_colours", @"ind_face_donate", @"ind_face_treeofcolours", @"ind_face_timezones", @"ind_face_slotmachine", @"ind_face_pulse", nil];
}

+ (NSArray*)uuidEndingArray {
    return [[NSArray alloc]initWithObjects:@"73920ffdb3b7", @"bab151d81975", @"c65a109260c7", @"302fdd6316da", @"ac7a28df9aca", @"666", @"7846d2c5b20c", @"f5cd1c761c0c", @"1e526f6e3634", @"1d6b111b1e26", nil];
}

+ (NSArray*)unlockTokenArray {
    return [[NSArray alloc]initWithObjects:@"fc020ef69262", @"44e14e616af6", @"79fc956bd024", @"1697f925ec7b", @"580df2b6b349", @"666", @"161f9ef90958", @"033da1cd67dd", @"3a0fd3ea89c5", @"f72e89335a89", nil];
}

+ (NSArray*)uuidArray {
    return [[NSArray alloc]initWithObjects:@"e1c75a76-27fc-4f9c-85b3-73920ffdb3b7", @"03a9a405-ba98-44ad-bca3-bab151d81975", @"1f626d76-38d8-4353-b930-c65a109260c7", @"e1fe3595-cb81-45c3-9720-302fdd6316da", @"3fabfdff-5f74-4bfb-8cfd-ac7a28df9aca", @"7f1c3fc2-bddd-4845-8737-b167454d276b", @"234e1842-d715-481c-9e04-7846d2c5b20c", @"bf69875c-bdc7-4110-b21c-f5cd1c761c0c", @"1b24ca10-591c-4d20-8e12-1e526f6e3634", @"de92cc22-eb6b-4229-9665-1d6b111b1e26", nil];
}

+ (NSArray*)locationArray {
    return [[NSArray alloc]initWithObjects:@"556dcfbc354a41c220000011", @"55883dc841241a5db40000f0", @"55883f2f41241abe5c0000e1", @"5588410449c1d102cd000114", @"55882b0c0021370a4b0000dc", @"552d9637ceb7830ea000007b", @"5595d996308fd768f30000b7", @"55992f97bec20eb7b5000038", @"559c557e12dc3229e5000084", @"559c5602b703a68da9000089", nil];
}

+ (NSInteger)getSettingsCount:(AppTypeCode)code {
    return (NSInteger)[[[NSArray alloc]initWithObjects:@6, @6, @4, @4, @5, @0, @3, @10, @10, @10, nil] objectAtIndex:code];
}

+ (NSString*)getAppUUID:(AppTypeCode)code {
    return [[self uuidArray] objectAtIndex:code];
}

+ (AppTypeCode)getAppTypeCode:(NSString*)UUID {
    return (AppTypeCode)[[self uuidArray] indexOfObject:UUID];
}

+ (Boolean)settingsEnabled:(AppTypeCode)code {
    switch(code){
        case APP_TYPE_TIMEDOCK:
            return NO;
        default:
            return YES;
    }
}

+ (NSString*)getAppNameFromType:(AppTypeCode)code {
    return [[[NSArray alloc]initWithObjects:@"speedometer", @"rightnighter", @"chunky", @"lines", @"colours", @"timedock", @"tree of colours", @"timezones", @"slot machine", @"pulse", nil] objectAtIndex:code];
}

+ (NSString*)getAppDescriptionFromType:(AppTypeCode)code {
    switch(code){
        case APP_TYPE_SPEEDOMETER:
            return @"Speedometer is a watchface that's sure to pop off your screen! \n\nIt features bars that fill up as time or other data progresses, such as the weekday, minute, and battery percentage.";
        case APP_TYPE_KNIGHTRIDER:
            return @"Kids of the 80s know exactly what this is. Have a \"voice box\" right on your wrist with a talking animation when the time changes. \n\nOn the lefthand side you see the date and on the opposite the remaining battery. RightNighter is also completely free for everybody.";
        case APP_TYPE_CHUNKY:
            return @"A nice square design where you can choose colors and see the time in nice big numbers. \n\n There are quite a few options as well, and goes well with any outfit you may wear!";
        case APP_TYPE_LINES:
            return @"A very simple yet very stylish face displaying nothing but the time and date.\n\nThere are quite a few settings here as well, and of course: customizable colours. This face is soon to have larger fonts!";
        case APP_TYPE_COLOURS:
            return @"This watchface is really gonna make your Pebble Time's display shine by changing the colours every minute, filling the black background with beautiful shades of colour. \n\nFind in settings the ability to change the width of these bars and other aspects of the face. Quite beautiful!";
        case APP_TYPE_TIMEDOCK:
            return @"Official watchface for TimeDock by Engineerable! Available on the appstore. \n\nSettings include being able to open the face when plugged in, animations, and more. Check it out, it's free.";
        case APP_TYPE_TREE_OF_COLOURS:
            return @"This one will truly live on the colour screen! Every minute a 'branch' grows randomly emulating a growing branch of a tree (hence the name). \n\nEvery hour it resets itself and since the growing and coloring happens randomly it always looks different.";
        case APP_TYPE_TIMEZONES:
            return @"Our take on a watch face with two timezones giving you many personalizing options too! \n\nThe inner circle shows the time for the first timezone (in the above example for Philipp’s timezone) and the outer one stands for the second timezone (Edwin, in the above example).";
        case APP_TYPE_SLOT_MACHINE:
            return @"A unique designed based around an actual slot machine. Watch the numbers shrink in and out of view as time passes by!\n\nSlot Machine comes with a few other handy features, such as battery bar and shake to animate, just in case.";
        case APP_TYPE_PULSE:
            return @"This is another face living through its animations. We could either let the circle grow every minute or have a pulse animation every minute changing the background color.\n\nThis will really make the Pebble Time’s colour display shine!";
        default:
            return @"app not found. clicking on settings or install may or may not do one or all of the following things: \n1. crash the app \n2. completely ruin your iphone \n3. delete ios and install the latest version of Android";
    }
}

@end

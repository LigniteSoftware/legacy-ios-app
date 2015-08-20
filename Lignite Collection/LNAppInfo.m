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

+ (NSInteger)uuidEndingKeyForIndex:(AppTypeCode)code {
    NSInteger array[] = {
        1098, 1035, 3012, 7856, 3242,
        0000, 7865, 3049, 5672, 3498,
        8799, 9831, 8309, 4874
    };
    return array[code];
}

+ (NSInteger)unlockTokenKeyForIndex:(AppTypeCode)code {
    NSInteger array[] = {
        546,  535,  392,  545,  2334,
        0000, 6345, 9569, 1932, 1030,
        3402, 8393, 2336, 5739
    };
    return array[code];
}

+ (NSArray*)skuArray {
    return [[NSArray alloc]initWithObjects:
            @"ind_face_speedometer", @"ind_face_rightnighter", @"ind_face_chunky", @"ind_face_lines", @"ind_face_colours",
            @"ind_face_donate", @"ind_face_treeofcolours", @"ind_face_timezones", @"ind_face_slotmachine", @"ind_face_pulse",
            @"ind_face_simplified", @"ind_face_personal", @"ind_face_beat", @"ind_face_equalizer", nil];
}

+ (NSArray*)uuidEndingArray {
    return [[NSArray alloc]initWithObjects:
            @"73920ffdb3b7", @"bab151d81975", @"c65a109260c7", @"302fdd6316da", @"ac7a28df9aca",
            @"665555555556", @"7846d2c5b20c", @"f5cd1c761c0c", @"1e526f6e3634", @"1d6b111b1e26",
            @"13777fac283a", @"2a21ac9d2bec", @"b886ceedb2b7", @"42943b55113c", nil];
}

+ (NSArray*)unlockTokenArray {
    return [[NSArray alloc]initWithObjects:
            @"fc020ef69262", @"44e14e616af6", @"79fc956bd024", @"1697f925ec7b", @"580df2b6b349",
            @"664343343436", @"161f9ef90958", @"033da1cd67dd", @"3a0fd3ea89c5", @"f72e89335a89",
            @"cd57aaadcbea", @"e72e89855f66", @"a69e13375a63", @"4b9cfdaca46e", nil];
}

+ (NSArray*)uuidArray {
    return [[NSArray alloc]initWithObjects:
            @"e1c75a76-27fc-4f9c-85b3-73920ffdb3b7", @"03a9a405-ba98-44ad-bca3-bab151d81975",
            @"1f626d76-38d8-4353-b930-c65a109260c7", @"e1fe3595-cb81-45c3-9720-302fdd6316da",
            @"3fabfdff-5f74-4bfb-8cfd-ac7a28df9aca", @"7f1c3fc2-bddd-4845-8737-b167454d276b",
            @"234e1842-d715-481c-9e04-7846d2c5b20c", @"bf69875c-bdc7-4110-b21c-f5cd1c761c0c",
            @"1b24ca10-591c-4d20-8e12-1e526f6e3634", @"de92cc22-eb6b-4229-9665-1d6b111b1e26",
            @"b32c5bbc-57d1-4f6c-91f1-13777fac283a", @"0bf39622-a77b-42b8-846a-2a21ac9d2bec",
            @"44067cdd-a10d-4e83-ba81-b886ceedb2b7", @"13738de7-03bc-45bd-a3fc-42943b55113c",
            nil];
}

+ (NSArray*)locationArray {
    return [[NSArray alloc]initWithObjects:
            @"556dcfbc354a41c220000011", @"55883dc841241a5db40000f0", @"55883f2f41241abe5c0000e1", @"5588410449c1d102cd000114",
            @"55882b0c0021370a4b0000dc", @"552d9637ceb7830ea000007b", @"5595d996308fd768f30000b7", @"55992f97bec20eb7b5000038",
            @"559c557e12dc3229e5000084", @"559c5602b703a68da9000089", @"55b517ee46a407265f00007b", @"55c05b70718511a83a00000b",
            @"55c8cf1c7fde01b16d000003", @"55c8cf1c7fde01b16d000003", @"55d13e160f995067ae000065", nil];
}

+ (NSArray*)nameArray {
    return [[NSArray alloc]initWithObjects:@"speedometer", @"rightnighter", @"chunky", @"lines", @"colours", @"timedock", @"tree of colours", @"timezones", @"slot machine", @"pulse", @"simplified analogue", @"personal", @"beat", @"equalizer", nil];
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
    return [[PebbleInfo nameArray] objectAtIndex:code];
}

+ (NSString*)getAppDescriptionFromType:(AppTypeCode)code {
    NSString *description = [NSString stringWithFormat:@"%@_description", [PebbleInfo getAppNameFromType:code]];
    return NSLocalizedString(description, nil);
}

@end

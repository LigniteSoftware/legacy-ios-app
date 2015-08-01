//
//  LNSettingsViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-31.
//
//

#import <DRColorPicker/DRColorPicker.h>
#import "LNSettingsViewController.h"
#import "SimpleTableViewController.h"
#import "PebbleInfo.h"
#import "DataFramework.h"
#import "LNSwitch.h"
#import "LNLabel.h"
#import "LNSlider.h"

@interface LNSettingsViewController () <SimpleTableViewControllerDelegate>

@property NSDictionary *settings_dict;
@property AppTypeCode settings_code;
@property NSMutableArray *label_array, *switch_array, *colour_label_array, *slider_array, *slider_value_label_array;
@property LNLabel *timezones_label;
@property int section_count;

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation LNSettingsViewController

int section_item_count[8];
int last_value;

- (void)setPebbleApp:(AppTypeCode)app {
    self.settings_code = app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"speedometer" ofType:@"json"]];
    
    NSError *error;
    self.settings_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    self.switch_array = [[NSMutableArray alloc]init];
    self.label_array = [[NSMutableArray alloc]init];
    self.colour_label_array = [[NSMutableArray alloc]init];
    self.slider_array = [[NSMutableArray alloc]init];
    self.slider_value_label_array = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [[self.settings_dict objectForKey:@"items"] count]; i++){
        NSDictionary *items = [[self.settings_dict objectForKey:@"items"] objectAtIndex:i];
        NSArray *itemsArray = [items objectForKey:@"items"];
        section_item_count[i] = (int)[itemsArray count];
    }
    
    self.section_count = (int)[[self.settings_dict objectForKey:@"items"] count];
    
    self.tableView.editing = false;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.allowsSelection = false;
    self.tableView.allowsSelectionDuringEditing = false;
    self.title = [[self.settings_dict objectForKey:@"name"] capitalizedString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpColourPicker:(LNLabel*)label {
    DRColorPickerBackgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    DRColorPickerBorderColor = [UIColor blackColor];
    DRColorPickerFont = [UIFont systemFontOfSize:16.0f];
    DRColorPickerLabelColor = [UIColor blackColor];
    
    DRColorPickerStoreMaxColors = 200;
    DRColorPickerShowSaturationBar = NO;
    DRColorPickerHighlightLastHue = YES;
    
    DRColorPickerUsePNG = NO;
    DRColorPickerJPEG2000Quality = 0.9f;
    DRColorPickerSharedAppGroup = nil;
    
    DRColorPickerViewController* vc = [DRColorPickerViewController newColorPickerWithColor:self.color];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.rootViewController.showAlphaSlider = NO;
    
    vc.rootViewController.addToFavoritesImage = nil;
    vc.rootViewController.favoritesImage = nil;
    vc.rootViewController.hueImage = nil;
    vc.rootViewController.wheelImage = nil;
    vc.rootViewController.importImage = nil;
    
    vc.rootViewController.importBlock = nil;
    
    vc.rootViewController.dismissBlock = ^(BOOL cancel){
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc){
        self.color = color;
        
        label.backgroundColor = color.rgbColor;
        
        //self.outerLabel.backgroundColor = color.rgbColor;
        self.color.alpha = 1.0;
        
        CGFloat floatR,floatG,floatB, a;
        [self.color.rgbColor getRed:&floatR green:&floatG blue: &floatB alpha: &a];
        
        int r = (int)(255.0 * floatR);
        int g = (int)(255.0 * floatG);
        int b = (int)(255.0 * floatB);
        
        NSString *string = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
        [DataFramework sendColourToPebble:string :(NSInteger)[label.json_object objectForKey:@"pebble_key"] :[label.json_object objectForKey:@"ios_key"] :[PebbleInfo getAppUUID:self.settings_code]];
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)changeSwitch:(id)sender{
    LNSwitch *changed_switch = sender;
    NSDictionary *item = changed_switch.json_object;
    [DataFramework sendBooleanToPebble:changed_switch.on :(NSInteger)[item objectForKey:@"pebble_key"] :[item objectForKey:@"ios_key"] :[PebbleInfo getAppUUID:self.settings_code]];
}

- (void)changeSlider:(id)sender{
    LNSlider *changed_slider = sender;
    UILabel *value_label = [self.slider_value_label_array objectAtIndex:[self.slider_array indexOfObject:sender]];
    value_label.text = [NSString stringWithFormat:@"%d", (int)floor(changed_slider.value)];
    
    if(last_value != (int)floor(changed_slider.value)){
        NSDictionary *item = changed_slider.json_object;
        [DataFramework sendNumberToPebble:[NSNumber numberWithInt:(int)floor(changed_slider.value)] :(NSInteger)[item objectForKey:@"pebble_key"] :[item objectForKey:@"ios_key"] :[PebbleInfo getAppUUID:self.settings_code]];
        last_value = floor(changed_slider.value);
    }
}

- (void)colourLabelTapped:(UITapGestureRecognizer*)sender {
    LNLabel *label = (LNLabel*)sender.view;
    [self setUpColourPicker:label];
}

- (void)itemSelectedatRow:(NSInteger)row{
    NSString *name = [[NSTimeZone knownTimeZoneNames] objectAtIndex:row];
    [self.timezones_label setText:[NSString stringWithFormat:@"Timezone: %@", name]];
    
    NSTimeZone *nba = [NSTimeZone localTimeZone];
    NSTimeZone *inTheZone = [NSTimeZone timeZoneWithName:[[NSTimeZone knownTimeZoneNames] objectAtIndex:row]];
    
    //long timeDifference = nba.getRawOffset() - inTheZone.getRawOffset() + nba.getDSTSavings() - inTheZone.getDSTSavings();
    long difference = nba.secondsFromGMT - inTheZone.secondsFromGMT;
    if(nba.daylightSavingTime)
        difference += nba.daylightSavingTimeOffset;
    if(inTheZone.daylightSavingTime)
        difference -= nba.daylightSavingTimeOffset;
    
    NSDictionary *item = self.timezones_label.json_object;
    
    [DataFramework sendNumberToPebble:[NSNumber numberWithLong:difference] :[[item objectForKey:@"pebble_key"] integerValue] :[item objectForKey:@"ios_key"] :[PebbleInfo getAppUUID:self.settings_code]];
    
    [DataFramework updateStringSetting:self.settings_code :(NSString*)name :[item objectForKey:@"ios_key"]];
}

- (void)timezonesButtonPushed{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    tableViewController.tableData = [NSTimeZone knownTimeZoneNames];
    tableViewController.navigationItem.title = @"Timezones";
    tableViewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.section_count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section_item_count[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    NSDictionary *items = [[self.settings_dict objectForKey:@"items"] objectAtIndex:[indexPath section]];
    NSArray *itemsArray = [items objectForKey:@"items"];
    NSDictionary *item = [itemsArray objectAtIndex:[indexPath item]];
    
    NSMutableDictionary *settings = [DataFramework getSettingsDictionaryForAppType:self.settings_code];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSString *item_type = [item objectForKey:@"type"];
    if([item_type isEqual:@"toggle"]){
        CGRect toggle_rect = CGRectMake(screenRect.size.width-60, 5.0f, 30.0f, 15.0f);
        
        LNSwitch *toggle = [[LNSwitch alloc]initWithFrame:toggle_rect];
        [toggle addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        
        toggle.json_object = item;
        toggle.on = [[settings objectForKey:[item objectForKey:@"ios_key"]] isEqual:@1];
        
        [self.switch_array insertObject:toggle atIndex:[self.switch_array count]];
        [cell addSubview:toggle];
    }
    else if([item_type isEqual:@"colour"]){
        CGRect colour_rect = CGRectMake(screenRect.size.width-50, 7.0f, 30.0f, 30.0f);
        
        LNLabel *colour_label = [[LNLabel alloc]initWithFrame:colour_rect];
        colour_label.backgroundColor = [DataFramework colorFromHexString:[settings objectForKey:[item objectForKey:@"ios_key"]]];
        
        colour_label.userInteractionEnabled = YES;
        colour_label.json_object = item;
        
        UITapGestureRecognizer *colour_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colourLabelTapped:)];
        [colour_label addGestureRecognizer:colour_recognizer];
        
        [self.colour_label_array insertObject:colour_label atIndex:[self.colour_label_array count]];
        [cell addSubview:colour_label];
    }
    else if([item_type isEqual:@"number_picker"]){
        CGRect slider_rect = CGRectMake(5.0f, 5.0f, screenRect.size.width-70, 30.0f);
        LNSlider *slider = [[LNSlider alloc]initWithFrame:slider_rect];
        
        slider.minimumValue = [[item objectForKey:@"min_value"] floatValue];
        slider.value = [[settings objectForKey:[item objectForKey:@"ios_key"]] floatValue];
        slider.maximumValue = [[item objectForKey:@"max_value"] floatValue];
        slider.json_object = item;
        
        [slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
        
        [self.slider_array insertObject:slider atIndex:[self.slider_array count]];
        [cell addSubview:slider];
        
        CGRect value_rect = CGRectMake(screenRect.size.width-45, 7.0f, 30.0f, 30.0f);
        UILabel *value_label = [[UILabel alloc]initWithFrame:value_rect];
        value_label.text = @"10";
        [self.slider_value_label_array insertObject:value_label atIndex:[self.slider_value_label_array count]];
        [cell addSubview:value_label];
    }
    else if([item_type isEqual:@"timezones"]){
        CGRect timezones_label_rect = CGRectMake(screenRect.origin.x+10, 7, screenRect.size.width-35.0f, 30.0f);
        self.timezones_label = [[LNLabel alloc]initWithFrame:timezones_label_rect];
        self.timezones_label.text = @"Timezone demo";
        
        UITapGestureRecognizer *timezone_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timezonesButtonPushed)];
        [self.timezones_label addGestureRecognizer:timezone_recognizer];
        self.timezones_label.userInteractionEnabled = YES;
        
        [cell addSubview:self.timezones_label];
    }
    
    if(![item_type isEqual:@"number_picker"]){
        CGRect label_rect = CGRectMake(screenRect.origin.x+10, 7, screenRect.size.width-35.0f, 30.0f);
        UILabel *label = [[UILabel alloc]initWithFrame:label_rect];
        [self.label_array insertObject:label atIndex:[self.label_array count]];
        label.text = [item objectForKey:@"label"];
        [cell addSubview:label];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[[self.settings_dict objectForKey:@"items"]objectAtIndex:section] objectForKey:@"title"];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  LNSettingsViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-31.
//
//

#import "LNSettingsViewController.h"
#import "SimpleTableViewController.h"
#import "LNAppInfo.h"
#import "LNDataFramework.h"
#import "LNSwitch.h"
#import "LNLabel.h"
#import "LNSlider.h"
#import "LNTextField.h"
#import "LNColourPicker.h"
#import "LNAlertView.h"

@interface LNSettingsViewController () <SimpleTableViewControllerDelegate, UIAlertViewDelegate>

@property NSDictionary *settings_dict;
@property AppTypeCode settings_code;
@property NSMutableArray *label_array, *switch_array, *colour_label_array, *slider_array, *slider_value_label_array, *text_field_array;
@property LNTextField *textfield_to_disappear;
@property LNLabel *timezones_label;
@property LNLabel *tapped_label;
@property int section_count;

@end

@implementation LNSettingsViewController

int section_item_count[8];
int last_value;


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
        if(alert.isGuard){
            [LNDataFramework sendLigniteGuardUnlockToPebble:alert.app settingsController:self];
        }
        else{
            [LNDataFramework sendDictionaryToPebble:alert.dictionary forApp:alert.app withSettingsController:self];
        }
    }
}

- (void)setAsAlertSettings {
    self.settings_code = APP_TYPE_NOTHING;
}

- (void)setPebbleApp:(AppTypeCode)app {
    self.settings_code = app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data;
    if(self.settings_code == APP_TYPE_NOTHING){
        data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lignite_settings" ofType:@"json"]];
    } else {
        data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[LNAppInfo getAppNameFromType:self.settings_code] ofType:@"json"]];
    }
    
    NSError *error;
    self.settings_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"error %@ dict %@", [error localizedDescription], self.settings_dict);

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
	if(self.settings_code == APP_TYPE_NOTHING){
		self.title = NSLocalizedString(@"settings", nil);
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

- (void)setUpColourPicker:(LNLabel*)label {
    LNColourPicker *picker = [[LNColourPicker alloc]init];
    picker.sourceLabel = label;
    picker.appType = self.settings_code;
    picker.loadColour = [self hexStringForColor:label.backgroundColor];
    [self showViewController:picker sender:self];
}

- (void)changeSwitch:(id)sender{
    LNSwitch *changed_switch = sender;
    NSDictionary *item = changed_switch.json_object;
    if(self.settings_code != APP_TYPE_NOTHING){
        [LNDataFramework sendBooleanToPebble:changed_switch.on pebbleKey:[[item objectForKey:@"pebble_key"] integerValue] storageKey:[item objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.settings_code] fromController:self];
    }
    else{
        [LNDataFramework updateBooleanSetting:APP_TYPE_NOTHING boolean:changed_switch.on key:[item objectForKey:@"storage_key"]];
    }
}

- (void)changeSlider:(id)sender{
    LNSlider *changed_slider = sender;
    UILabel *value_label = [self.slider_value_label_array objectAtIndex:[self.slider_array indexOfObject:sender]];
    value_label.text = [NSString stringWithFormat:@"%d", (int)floor(changed_slider.value)];
    
    if(last_value != (int)floor(changed_slider.value)){
        NSDictionary *item = changed_slider.json_object;
        [LNDataFramework sendNumberToPebble:[NSNumber numberWithInt:(int)floor(changed_slider.value)] pebbleKey:[[item objectForKey:@"pebble_key"] integerValue] storageKey:[item objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.settings_code] fromController:self];
        last_value = floor(changed_slider.value);
    }
}

- (void)colourLabelTapped:(UITapGestureRecognizer*)sender {
    UITableViewCell *cell = (UITableViewCell*)sender.view;
	LNLabel *label;
	NSArray *colour_array = [NSArray arrayWithArray:self.colour_label_array];
	for(int i = 0; i < [[cell subviews] count]; i++){
		for(int colour_index = 0; colour_index < [colour_array count]; colour_index++){
			if([[[cell subviews] objectAtIndex:i] isEqual:[colour_array objectAtIndex:colour_index]]){
				label = [[cell subviews] objectAtIndex:i];
			}
		}
	}
	if(label == nil){
		NSLog(@"label is nil!");
	}
	else{
		NSLog(@"label isn't: %@", label.json_object);
	}
    [self setUpColourPicker:label];
}

- (void)itemSelectedatRow:(NSInteger)row {
    if(self.settings_code == APP_TYPE_TIMEZONES){
        NSString *name = [[NSTimeZone knownTimeZoneNames] objectAtIndex:row];
        [self.timezones_label setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"timezone", nil), name]];
        
        NSTimeZone *nba = [NSTimeZone localTimeZone];
        NSTimeZone *inTheZone = [NSTimeZone timeZoneWithName:[[NSTimeZone knownTimeZoneNames] objectAtIndex:row]];
        
        //long timeDifference = nba.getRawOffset() - inTheZone.getRawOffset() + nba.getDSTSavings() - inTheZone.getDSTSavings();
        long difference = nba.secondsFromGMT - inTheZone.secondsFromGMT;
        if(nba.daylightSavingTime)
            difference += nba.daylightSavingTimeOffset;
        if(inTheZone.daylightSavingTime)
            difference -= nba.daylightSavingTimeOffset;
        
        NSDictionary *item = self.timezones_label.json_object;

        [LNDataFramework sendNumberToPebble:[NSNumber numberWithLong:difference] pebbleKey:[[item objectForKey:@"pebble_key"] integerValue] storageKey:[item objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.settings_code] fromController:self];
        
        [LNDataFramework updateStringSetting:self.settings_code string:(NSString*)name key:[item objectForKey:@"storage_key"]];
    }
	else if(self.settings_code == APP_TYPE_NOTHING){
		LNLabel *label = self.tapped_label;
		NSString *name = [[label.json_object objectForKey:@"list"] objectAtIndex:row];
		[self.tapped_label setText:NSLocalizedString(name, nil)];
		
		[LNDataFramework updateNumberSetting:APP_TYPE_NOTHING number:[NSNumber numberWithInt:(int)row] key:[label.json_object objectForKey:@"storage_key"]];
	}
    else{
        LNLabel *label = self.tapped_label;
        NSString *name = [[label.json_object objectForKey:@"list"] objectAtIndex:row];
        [self.tapped_label setText:NSLocalizedString(name, nil)];
        
        [LNDataFramework sendNumberToPebble:[NSNumber numberWithInteger:row] pebbleKey:[[label.json_object objectForKey:@"pebble_key"] integerValue] storageKey:[label.json_object objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.settings_code] fromController:self];
    }
}

- (void)timezonesButtonPushed{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    
    tableViewController.tableData = [NSTimeZone knownTimeZoneNames];
    tableViewController.navigationItem.title = NSLocalizedString(@"timezones", nil);
    tableViewController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)listLabelTapped:(UITapGestureRecognizer*)recognizer {
    LNLabel *label = (LNLabel*) recognizer.view;
    
    self.tapped_label = label;
    
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleListTableVC"];
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    
    NSArray *array = [label.json_object objectForKey:@"list"];
    NSMutableArray *localizedArray = [[NSMutableArray alloc]init];
    for(int i = 0; i < [array count]; i++){
        [localizedArray insertObject:NSLocalizedString([array objectAtIndex:i], nil) atIndex:i];
    }
    
    NSLog(@"array of %@, localized array of %@", array, localizedArray);
    
    tableViewController.tableData = localizedArray;
    tableViewController.navigationItem.title = NSLocalizedString([label.json_object objectForKey:@"label"], nil);
    tableViewController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(LNTextField *)textField {
    NSLog(@"%@ hello", textField);
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    NSLog(@"Make keyboard disappear");
    [self textFieldShouldReturn:self.textfield_to_disappear];
    for(int i = 0; i < [self.text_field_array count]; i++){
        LNTextField *field = [self.text_field_array objectAtIndex:i];
        NSLog(@"sending %@ to key %d %@", field.text, [[field.json_object objectForKey:@"pebble_key"] intValue], [field.json_object objectForKey:@"storage_key"]);
        [LNDataFramework sendStringToPebble:field.text pebbleKey:[[field.json_object objectForKey:@"pebble_key"] integerValue] storageKey:[field.json_object objectForKey:@"storage_key"] appUUID:[LNAppInfo getAppUUID:self.settings_code] fromController:self];
    }
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
    
    NSMutableDictionary *settings = [LNDataFramework getSettingsDictionaryForAppType:self.settings_code];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSString *item_type = [item objectForKey:@"type"];
    if([item_type isEqual:@"toggle"]){
        CGRect toggle_rect = CGRectMake(screenRect.size.width-60, 5.0f, 30.0f, 15.0f);
        
        LNSwitch *toggle = [[LNSwitch alloc]initWithFrame:toggle_rect];
        [toggle addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        
        toggle.json_object = item;
        toggle.on = [[settings objectForKey:[item objectForKey:@"storage_key"]] isEqual:@1];
        
        [self.switch_array insertObject:toggle atIndex:[self.switch_array count]];
        [cell addSubview:toggle];
    }
    else if([item_type isEqual:@"colour"]){
        CGRect colour_rect = CGRectMake(screenRect.size.width-50, 7.0f, 30.0f, 30.0f);
        
        LNLabel *colour_label = [[LNLabel alloc]initWithFrame:colour_rect];
        colour_label.backgroundColor = [LNDataFramework colorFromHexString:[settings objectForKey:[item objectForKey:@"storage_key"]]];
        
        colour_label.userInteractionEnabled = YES;
        colour_label.json_object = item;
		
        colour_label.layer.masksToBounds = YES;
        colour_label.layer.borderWidth = 0.0;
        colour_label.layer.cornerRadius = 3.0;
        
        [self.colour_label_array insertObject:colour_label atIndex:[self.colour_label_array count]];
        [cell addSubview:colour_label];
		
		UITapGestureRecognizer *colour_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colourLabelTapped:)];
		cell.userInteractionEnabled = YES;
		[cell addGestureRecognizer:colour_recognizer];
    }
    else if([item_type isEqual:@"number_picker"]){
        CGRect slider_rect = CGRectMake(10, 5.0f, screenRect.size.width-80, 30.0f);
        LNSlider *slider = [[LNSlider alloc]initWithFrame:slider_rect];
		
        slider.minimumValue = [[item objectForKey:@"min_value"] floatValue];
        slider.maximumValue = [[item objectForKey:@"max_value"] floatValue];
		slider.value = [[settings objectForKey:[item objectForKey:@"storage_key"]] floatValue];
        slider.userInteractionEnabled = YES;
		slider.continuous = NO;
        slider.json_object = item;
        
        [slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
        
        [self.slider_array insertObject:slider atIndex:[self.slider_array count]];
        [cell addSubview:slider];
		
        CGRect value_rect = CGRectMake(screenRect.size.width-45, 7.0f, 30.0f, 30.0f);
        UILabel *value_label = [[UILabel alloc]initWithFrame:value_rect];
		value_label.text = [NSString stringWithFormat:@"%ld", (long)[[settings objectForKey:[item objectForKey:@"storage_key"]]integerValue]];
        [self.slider_value_label_array insertObject:value_label atIndex:[self.slider_value_label_array count]];
        [cell addSubview:value_label];
    }
    else if([item_type isEqual:@"timezones"]){
        CGRect timezones_label_rect = CGRectMake(14, 7, screenRect.size.width-35.0f, 30.0f);
        self.timezones_label = [[LNLabel alloc]initWithFrame:timezones_label_rect];
		NSString *timezoneString = [settings objectForKey:[item objectForKey:@"storage_key"]];
		if(timezoneString == nil){
			timezoneString = NSLocalizedString(@"none", nil);
		}
        self.timezones_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"timezone", nil), timezoneString];
        
        self.timezones_label.json_object = item;
        
        UITapGestureRecognizer *timezone_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timezonesButtonPushed)];
        [self.timezones_label addGestureRecognizer:timezone_recognizer];
        self.timezones_label.userInteractionEnabled = YES;
        
        [cell addSubview:self.timezones_label];
    }
    else if([item_type isEqual:@"textfield"]){
        CGRect textfield_rect = CGRectMake(screenRect.origin.x+10, 7, screenRect.size.width-70, 30.0f);
        LNTextField *textfield = [[LNTextField alloc]initWithFrame:textfield_rect];
        textfield.borderStyle = UITextBorderStyleRoundedRect;
        textfield.json_object = item;
        textfield.text = [settings objectForKey:[item objectForKey:@"storage_key"]];
        
        if(!self.text_field_array){
            self.text_field_array = [[NSMutableArray alloc]init];
        }
        
        [self.text_field_array addObject:textfield];
        
        UITapGestureRecognizer *keyboard_down_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
        [self.view addGestureRecognizer:keyboard_down_recognizer];
        
        self.textfield_to_disappear = textfield;
        [cell addSubview:textfield];
		
		CGRect sendbutton_rect = CGRectMake(textfield_rect.origin.x+textfield_rect.size.width+5, 7, 50, 30.0f);
		UIButton *send_button = [[UIButton alloc]initWithFrame:sendbutton_rect];
		//send_button.titleLabel.text = NSLocalizedString(@"send", nil);
		send_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
		[send_button setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
		[send_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		[send_button addTarget:self action:@selector(makeKeyboardDisappear:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:send_button];
    }
    else if([item_type isEqual:@"list"]){
        CGRect list_rect = CGRectMake(screenRect.origin.x+14, 7, screenRect.size.width-20, 30.0f);
        LNLabel *list_label = [[LNLabel alloc]initWithFrame:list_rect];
        list_label.json_object = item;
        list_label.text = NSLocalizedString([item objectForKey:@"label"], nil);
        list_label.userInteractionEnabled = YES;
        
        if([settings objectForKey:[item objectForKey:@"storage_key"]]){
            list_label.text = NSLocalizedString([[item objectForKey:@"list"] objectAtIndex:[[settings objectForKey:[item objectForKey:@"storage_key"]] integerValue]], nil);
            NSLog(@"%@ for %@", [settings objectForKey:[item objectForKey:@"storage_key"]], [item objectForKey:@"storage_key"]);
        }
        else{
            NSLog(@"Nothing for %@", [item objectForKey:@"storage_key"]);
        }
        
        UITapGestureRecognizer *list_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listLabelTapped:)];
        [list_label addGestureRecognizer:list_recognizer];
        
        [self.label_array addObject:list_label];
        [cell addSubview:list_label];
    }
    
    if(![item_type isEqual:@"number_picker"] && ![item_type isEqual:@"textfield"] && ![item_type isEqual:@"list"]){
        CGRect label_rect = CGRectMake(screenRect.origin.x+14, 7, screenRect.size.width-35.0f, 30.0f);
        LNLabel *label = [[LNLabel alloc]initWithFrame:label_rect];
        [self.label_array insertObject:label atIndex:[self.label_array count]];
        label.text = NSLocalizedString([item objectForKey:@"label"], nil);
        [cell addSubview:label];
    }
	
	if([item_type isEqual:@"list"] || [item_type isEqual:@"timezones"]){
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString([[[self.settings_dict objectForKey:@"items"]objectAtIndex:section] objectForKey:@"title"], nil);
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

//
//  LNSettingsViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-31.
//
//

#import "LNSettingsViewController.h"
#import "PebbleInfo.h"
#import "DataFramework.h"
#import "LNSwitch.h"

@interface LNSettingsViewController ()

@property NSDictionary *settings_dict;
@property AppTypeCode settings_code;
@property NSMutableArray *label_array, *switch_array, *colour_label_array, *slider_array, *slider_value_label_array;
@property int section_count;

@end

@implementation LNSettingsViewController

int section_item_count[8];

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
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.section_count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section_item_count[section];
}

- (void)changeSwitch:(id)sender{
    LNSwitch *changed_switch = sender;
    NSDictionary *item = changed_switch.json_object;
    [DataFramework sendBooleanToPebble:changed_switch.on :(NSInteger)[item objectForKey:@"pebble_key"]:[item objectForKey:@"ios_key"] :[PebbleInfo getAppUUID:self.settings_code]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    NSDictionary *items = [[self.settings_dict objectForKey:@"items"] objectAtIndex:[indexPath section]];
    NSArray *itemsArray = [items objectForKey:@"items"];
    NSDictionary *item = [itemsArray objectAtIndex:[indexPath item]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSString *item_type = [item objectForKey:@"type"];
    if([item_type isEqual:@"toggle"]){
        CGRect toggle_rect = CGRectMake(screenRect.size.width-60, 5.0f, 30.0f, 15.0f);
        LNSwitch *toggle = [[LNSwitch alloc]initWithFrame:toggle_rect];
        [toggle addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        toggle.json_object = item;
        [self.switch_array insertObject:toggle atIndex:[self.switch_array count]];
        [cell addSubview:toggle];
    }
    else if([item_type isEqual:@"colour"]){
        CGRect colour_rect = CGRectMake(screenRect.size.width-50, 7.0f, 30.0f, 30.0f);
        UILabel *colour_label = [[UILabel alloc]initWithFrame:colour_rect];
        colour_label.backgroundColor = [[UIColor alloc]initWithRed:255.0f green:0.0f blue:0.0f alpha:255.0f];
        [self.colour_label_array insertObject:colour_label atIndex:[self.colour_label_array count]];
        [cell addSubview:colour_label];
    }
    else if([item_type isEqual:@"number_picker"]){
        CGRect slider_rect = CGRectMake(5.0f, 5.0f, screenRect.size.width-70, 30.0f);
        UISlider *slider = [[UISlider alloc]initWithFrame:slider_rect];
        slider.minimumValue = 0.0f;
        slider.value = 5.0f;
        slider.maximumValue = 10.0f;
        [self.slider_array insertObject:slider atIndex:[self.slider_array count]];
        [cell addSubview:slider];
        
        CGRect value_rect = CGRectMake(screenRect.size.width-45, 7.0f, 30.0f, 30.0f);
        UILabel *value_label = [[UILabel alloc]initWithFrame:value_rect];
        value_label.text = @"10";
        [self.slider_value_label_array insertObject:value_label atIndex:[self.slider_value_label_array count]];
        [cell addSubview:value_label];
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

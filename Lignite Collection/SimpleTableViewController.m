//
//  SimpleTableViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-08.
//
//

#import "SimpleTableViewController.h"

@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(itemSelectedatRow:)]) {
        [self.delegate itemSelectedatRow:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (IBAction)cancelPressed:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
	/*
	if([[self.tableData objectAtIndex:0] containsString:@"/"]){
		NSLog(@"Is timezones");
		for(int i = 0; i < [self.tableData count]; i++){
			NSString *tableString = [self.tableData objectAtIndex:i];
					NSRange range = [string rangeOfString:searchKeyword];
					if (range.location == NSNotFound) {
			NSLog(@"string was not found");
					} else {
			NSLog(@"position %lu", (unsigned long)range.location);
					}
			NSString *location = [tableString substringFromIndex:[tableString string]]
		}
	}
	 */
}

@end

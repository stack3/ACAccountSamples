//
//  STViewController.m
//  ACAccountSamples
//
//  Created by EIMEI on 2013/06/17.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "STViewController.h"
#import "STTwitterViewController.h"
#import "STFacebookViewController.h"

typedef enum {
    _MenuItemTwitter,
    _MenuItemFacebook
} _MenuItems;

@implementation STViewController {
    IBOutlet __weak UITableView *_tableView;
    __strong NSMutableArray *_rows;
}

- (id)init
{
    self = [super initWithNibName:@"STViewController" bundle:nil];
    if (self) {
        self.title = @"Menu";
        
        _rows = [NSMutableArray arrayWithCapacity:10];
        [_rows addObject:@"Twitter"];
        [_rows addObject:@"Facebook"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *row = [_rows objectAtIndex:indexPath.row];
    cell.textLabel.text = row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _MenuItemTwitter) {
        STTwitterViewController *con = [[STTwitterViewController alloc] init];
        [self.navigationController pushViewController:con animated:YES];
    } else if (indexPath.row == _MenuItemFacebook) {
        STFacebookViewController *con = [[STFacebookViewController alloc] init];
        [self.navigationController pushViewController:con animated:YES];
    }
}

@end

//
//  MenuViewController.m
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import "MenuViewController.h"
#import "PlugIn.h"

@implementation MenuViewController

- (id)init {
    if (self = [super init]) {
        self.navigationItem.title = NSLocalizedString(@"Cate | Call And Text Eraser", nil);
    }
    return self;
}

#pragma mark - Private
- (void)switchValueChanged:(UISwitch *)sender {
    [PlugIn setEnabled:sender.on];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.on = [PlugIn enabled];
    [toggle addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = toggle;
    cell.textLabel.text = NSLocalizedString(@"Enabled", nil);
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end

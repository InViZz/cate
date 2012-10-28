//
//  ContactsViewController.m
//  Cate
//
//  Created by shaohua on 10/27/12.
//  Copyright (c) 2012 shaohua. All rights reserved.
//

#import "ContactsViewController.h"
#import "PlugIn.h"

@interface ContactsViewController () {
    NSMutableArray *_contacts;
    BOOL _dirty;
}

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTapped)];
        _contacts = [PlugIn blacklisted];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_dirty) {
        [PlugIn setBlacklisted:_contacts];
        _dirty = NO;
    }
}

#pragma mark - Private
- (void)rightBarButtonTapped {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self dismissModalViewControllerAnimated:YES];

    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);

    NSMutableArray *numbers = [NSMutableArray array];
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i = 0; i < ABMultiValueGetCount(phone); ++i) {
        NSString *value = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, i);
        // remove '-' and ' '
        value = [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        [numbers addObject:value];
    }
    NSDictionary *object = @{
        @"firstName": firstName,
        @"lastName": lastName,
        @"numbers": numbers,
    };
    [_contacts addObject:object];
    _dirty = YES;
    [self.tableView reloadData];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *person = [_contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person[@"lastName"], person[@"firstName"]];
    return cell;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_contacts removeObjectAtIndex:indexPath.row];
        [PlugIn setBlacklisted:_contacts];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end

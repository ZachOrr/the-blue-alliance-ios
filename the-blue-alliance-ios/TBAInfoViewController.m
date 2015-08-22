//
//  TBAInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAInfoViewController.h"
#import "Team.h"
#import "Event.h"
#import "Media.h"
#import "OrderedDictionary.h"

static NSString *const InfoCellReuseIdentifier = @"InfoCell";

@interface TBAInfoViewController ()

@property (nonatomic, assign) BOOL expandSponsors;
@property (nonatomic, strong) OrderedDictionary *infoDictionary;

@end

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.team) {
        return 3;
    } else if (self.event) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];

#warning this needs to change based on the data we do/don't have
    if (self.team.location && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"from %@", self.team.location];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.team.name && indexPath.row == 1) {
        cell.textLabel.text = self.team.name;
        cell.textLabel.numberOfLines = 2;
        
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.tintColor = [UIColor colorWithRed:0.79 green:0.79 blue:0.81 alpha:1];
    } else if (self.event.dateString && indexPath.row == 0) {
        cell.textLabel.text = self.event.dateString;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.team.website && indexPath.row == 2) {
        cell.textLabel.text = self.team.website;

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (self.event.location && indexPath.row == 1) {
        cell.textLabel.text = self.event.location;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleString];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.textLabel.text = [self titleString];
        tableViewHeaderFooterView.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [self.infoDictionary keyAtIndex:indexPath.row];
    if ([key isEqualToString:@"sponsors"]) {
        self.expandSponsors = !self.expandSponsors;
        [self.tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (NSString *)titleString {
    if (self.team) {
        return [self.team nickname];
    } else {
        return self.event.name;
    }
}

@end

//
//  MatchViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MatchViewController.h"
#import "TBARefreshTableViewController.h"
#import "TBAMatchViewController.h"
#import "TBAMatchBreakdownViewController.h"
#import "Match.h"
#import "Event.h"

static NSString *const MatchViewControllerEmbed             = @"MatchViewControllerEmbed";
static NSString *const MatchBreakdownViewControllerEmbed    = @"MatchBreakdownViewControllerEmbed";

typedef NS_ENUM(NSInteger, TBAMatchSegment) {
    TBAMatchSegmentMatch = 0,
    TBAMatchSegmentBreakdown
};

@interface MatchViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAMatchViewController *matchViewController;
@property (nonatomic, weak) IBOutlet UIView *matchView;

@property (nonatomic, strong) TBAMatchBreakdownViewController *matchBreakdownViewController;
@property (nonatomic, weak) IBOutlet UIView *matchBreakdownView;

@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.matchViewController, self.matchBreakdownViewController];
    self.containerViews = @[self.matchView, self.matchBreakdownView];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [self.match shortCompLevelString], self.match.matchNumber];
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.match.event friendlyNameWithYear:YES]];
    
    [self updateInterface];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBAMatchSegmentMatch) {
        [self showView:self.matchView];
    } else if (self.segmentedControl.selectedSegmentIndex == TBAMatchSegmentBreakdown) {
        [self showView:self.matchBreakdownView];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MatchViewControllerEmbed]) {
        self.matchViewController = segue.destinationViewController;
        self.matchViewController.persistenceController = self.persistenceController;
        self.matchViewController.match = self.match;
    } else if ([segue.identifier isEqualToString:MatchBreakdownViewControllerEmbed]) {
        self.matchBreakdownViewController = segue.destinationViewController;
        self.matchBreakdownViewController.persistenceController = self.persistenceController;
        self.matchBreakdownViewController.match = self.match;
    }
}

@end
//
//  SLExpandableTableViewController.m
//  SLExpandableTableViewTests
//
//  Created by Oliver Letterer on 19.02.14.
//  Copyright 2014 Sparrow-Labs. All rights reserved.
//

#import "SLExpandableTableViewController.h"

@interface SLExpandableTableViewControllerHeaderCell : UITableViewCell <UIExpandingTableViewCell>

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;
- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated;

@end

@implementation SLExpandableTableViewControllerHeaderCell

- (NSString *)accessibilityLabel
{
    return self.textLabel.text;
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        [self _updateDetailTextLabel];
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        [self _updateDetailTextLabel];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _updateDetailTextLabel];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)_updateDetailTextLabel
{
    if (self.isLoading) {
        self.detailTextLabel.text = @"Loading data";
    } else {
        switch (self.expansionStyle) {
            case UIExpansionStyleExpanded:
                self.detailTextLabel.text = @"Click to collapse";
                break;
            case UIExpansionStyleCollapsed:
                self.detailTextLabel.text = @"Click to expand";
                break;
        }
    }
}

@end


@interface SLExpandableTableViewController ()

@property (nonatomic, strong) NSArray *firstSectionStrings;
@property (nonatomic, strong) NSArray *secondSectionStrings;

@property (nonatomic, strong) NSMutableArray *sectionsArray;

@property (nonatomic, strong) NSMutableIndexSet *expandableSections;

@end



@implementation SLExpandableTableViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        _firstSectionStrings = @[ @"Section 0 Row 0", @"Section 0 Row 1", @"Section 0 Row 2", @"Section 0 Row 3" ];
        _secondSectionStrings = @[ @"Section 1 Row 0", @"Section 1 Row 1", @"Section 1 Row 2", @"Section 1 Row 3", @"Section 1 Row 4" ];

        _sectionsArray = @[ _firstSectionStrings, _secondSectionStrings ].mutableCopy;
        _expandableSections = [NSMutableIndexSet indexSet];
    }
    return self;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - View lifecycle

- (void)loadView
{
    SLExpandableTableView *tableView = [[SLExpandableTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = tableView;
}

#pragma mark - SLExpandableTableViewDatasource

- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section
{
    return YES;
}

- (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section
{
    return ![self.expandableSections containsIndex:section];
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"SLExpandableTableViewControllerHeaderCell";
    SLExpandableTableViewControllerHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[SLExpandableTableViewControllerHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Section %ld", (long)section];

    return cell;
}

#pragma mark - SLExpandableTableViewDelegate

- (void)tableView:(SLExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.expandableSections addIndex:section];
        [tableView expandSection:section animated:YES];
    });
}

- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
    [self.expandableSections removeIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        return 44.0 * 2.0;
    }

    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = self.sectionsArray[section];
    return dataArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray *dataArray = self.sectionsArray[indexPath.section];
    cell.textLabel.text = dataArray[indexPath.row - 1];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.sectionsArray removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Private category implementation ()

@end

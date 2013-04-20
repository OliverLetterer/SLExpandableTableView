//
//  SampleViewController.m
//  UIExpandableTableViewSample
//
//  Created by me on 27.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "SampleViewController.h"
#import "UIExpandableTableView.h"
#import "GHCollapsingAndSpinningTableViewCell.h"

#define kUITableExpandableSection       1

@implementation SampleViewController

#pragma mark - View lifecycle

- (void)loadView {
    self.tableView = [[UIExpandableTableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f) style:UITableViewStylePlain];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    // return YES, if the section should be expandable
    return section == kUITableExpandableSection;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    // return YES, if you need to download data to expand this section. tableView will call tableView:downloadDataForExpandableSection: for this section
    return !_didDownloadData;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"GHCollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == kUITableExpandableSection) {
        cell.textLabel.text = @"Expand this section";
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    // download your data here
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        // save your state, that you did download the data
        _didDownloadData = YES;
        // call [tableView cancelDownloadInSection:section]; if your download failed
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
        for (NSUInteger i = 0; i < 10; i++) {
            [array addObject:[NSString stringWithFormat:@"Data %d", i]];
        }
        _dataArray = [array copy];
        
        // and expand this section after download completed
        [tableView expandSection:section animated:YES];
    });
}

- (void)tableView:(UIExpandableTableView *)tableView willExpandSection:(NSUInteger)section animated:(BOOL)animated
{
    NSLog(@"%@: %lu", NSStringFromSelector(_cmd), (unsigned long)section);
}

- (void)tableView:(UIExpandableTableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated
{
    NSLog(@"%@: %lu", NSStringFromSelector(_cmd), (unsigned long)section);
}

- (void)tableView:(UIExpandableTableView *)tableView willCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
    NSLog(@"%@: %lu", NSStringFromSelector(_cmd), (unsigned long)section);
}

- (void)tableView:(UIExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
    NSLog(@"%@: %lu", NSStringFromSelector(_cmd), (unsigned long)section);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableExpandableSection) {
        return _dataArray.count + 1;        // return +1 here, because this section can be expanded
    } else if (section == 0) {
        return 3;
    }
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundView = backgroundView;
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    // Configure the cell...
    
    if (indexPath.section == kUITableExpandableSection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = _dataArray[indexPath.row - 1];     // use -1 here, because the expanding cell is always at row 0
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Section: %d, Row: %d", indexPath.section, indexPath.row];
        cell.backgroundView.backgroundColor = [UIColor yellowColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableExpandableSection) {
        SampleViewController *viewController = [[SampleViewController alloc] init];
        viewController.title = _dataArray[indexPath.row - 1];        // dont forget -1 here too
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end

//
//  Tests.m
//  Tests
//
//  Created by Oliver Letterer on 19.02.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "SLExpandableTableViewController.h"

@interface Tests : XCTestCase @end

@implementation Tests

- (void)testThatOneCanSetTheDelegateToNil
{
    SLExpandableTableViewController *viewController = [[SLExpandableTableViewController alloc] initWithStyle:UITableViewStylePlain];
    if (!viewController.isViewLoaded) {
        [viewController loadView];
        [viewController viewDidLoad];
    }

    XCTAssertNotNil(viewController.tableView.delegate);
    XCTAssertNotNil(viewController.tableView.dataSource);

    viewController.tableView.delegate = nil;
    viewController.tableView.dataSource = nil;

    XCTAssertNil(viewController.tableView.delegate);
    XCTAssertNil(viewController.tableView.dataSource);
}

- (void)testThatUserCanExpandAndCollapseSection0
{
    [tester tapViewWithAccessibilityLabel:@"Section 0"];
    [tester waitForViewWithAccessibilityLabel:@"Section 0 Row 1"];
    [tester tapViewWithAccessibilityLabel:@"Section 0"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Section 0 Row 1"];
}

- (void)testThatUserCanExpandAndCollapseSection0And1
{
    [tester tapViewWithAccessibilityLabel:@"Section 0"];
    [tester tapViewWithAccessibilityLabel:@"Section 1"];
    [tester waitForViewWithAccessibilityLabel:@"Section 0 Row 1"];
    [tester waitForViewWithAccessibilityLabel:@"Section 1 Row 1"];

    [tester tapViewWithAccessibilityLabel:@"Section 0"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Section 0 Row 1"];

    [tester tapViewWithAccessibilityLabel:@"Section 1"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Section 1 Row 1"];
}

@end

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
#import <SLExpandableTableView.h>
@import ObjectiveC.message;

@interface Tests : XCTestCase @end

@implementation Tests

- (void)testThatOneCanSetTheDelegateToNil
{
    SLExpandableTableViewController *viewController = [[SLExpandableTableViewController alloc] initWithStyle:UITableViewStylePlain];
    if (!viewController.isViewLoaded) {
        [viewController loadView];
        [viewController viewDidLoad];
    }

    SLExpandableTableView *tableView = [[SLExpandableTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    tableView.delegate = viewController;
    tableView.dataSource = viewController;

    XCTAssertNotNil(tableView.delegate);
    XCTAssertNotNil(tableView.dataSource);

    tableView.delegate = nil;
    tableView.dataSource = nil;

    struct objc_super super = {
        .receiver = tableView,
        .super_class = [UITableView class]
    };
    ((void(*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&super, @selector(setDelegate:), nil);
    ((void(*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&super, @selector(setDataSource:), nil);
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

- (void)testThatUserCanExpandAndCollapseSection0And1ThenDelete
{
    [tester tapViewWithAccessibilityLabel:@"Section 0"];
    [tester waitForViewWithAccessibilityLabel:@"Section 0 Row 1"];
    
    [tester swipeViewWithAccessibilityLabel:@"Section 0" inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Section 0"];
}

@end

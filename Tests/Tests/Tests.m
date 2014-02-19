//
//  Tests.m
//  Tests
//
//  Created by Oliver Letterer on 19.02.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <KIF/KIF.h>

@interface Tests : SenTestCase @end

@implementation Tests

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

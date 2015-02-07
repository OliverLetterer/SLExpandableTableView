//
//  SLExpandableTableView.m
//  iGithub
//
//  Created by me on 11.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "SLExpandableTableView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static BOOL protocol_containsSelector(Protocol *protocol, SEL selector)
{
    return protocol_getMethodDescription(protocol, selector, YES, YES).name != NULL || protocol_getMethodDescription(protocol, selector, NO, YES).name != NULL;
}



@interface SLExpandableTableView ()

@property (nonatomic, retain) NSMutableDictionary *expandableSectionsDictionary;
@property (nonatomic, retain) NSMutableDictionary *showingSectionsDictionary;
@property (nonatomic, retain) NSMutableDictionary *downloadingSectionsDictionary;
@property (nonatomic, retain) NSMutableDictionary *animatingSectionsDictionary;

@property (nonatomic, retain) UIView *storedTableHeaderView;
@property (nonatomic, retain) UIView *storedTableFooterView;

- (void)downloadDataInSection:(NSInteger)section;

- (void)_resetExpansionStates;

@end



@implementation SLExpandableTableView

#pragma mark - setters and getters

- (id<UITableViewDelegate>)delegate {
    return [super delegate];
}

- (void)setDelegate:(id<SLExpandableTableViewDelegate>)delegate {
    _myDelegate = delegate;
    [super setDelegate:self];
}

- (id<UITableViewDataSource>)dataSource {
    return [super dataSource];
}

- (void)setDataSource:(id<SLExpandableTableViewDatasource>)dataSource {
    _myDataSource = dataSource;
    [super setDataSource:self];
}

- (void)setTableFooterView:(UIView *)tableFooterView {
    if (tableFooterView != _storedTableFooterView) {
        [super setTableFooterView:nil];
        _storedTableFooterView = tableFooterView;
        [self reloadData];
    }
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    if (tableHeaderView != _storedTableHeaderView) {
        [super setTableHeaderView:nil];
        _storedTableHeaderView = tableHeaderView;
        [self reloadData];
    }
}

- (void)setOnlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty:(BOOL)onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty {
    if (_onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty != onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty) {
        _onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty = onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty;
        [self reloadData];
    }
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (protocol_containsSelector(@protocol(UITableViewDataSource), aSelector)) {
        return [super respondsToSelector:aSelector] || [_myDataSource respondsToSelector:aSelector];
    } else if (protocol_containsSelector(@protocol(UITableViewDelegate), aSelector)) {
        return [super respondsToSelector:aSelector] || [_myDelegate respondsToSelector:aSelector];
    }

    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (protocol_containsSelector(@protocol(UITableViewDataSource), aSelector)) {
        return _myDataSource;
    } else if (protocol_containsSelector(@protocol(UITableViewDelegate), aSelector)) {
        return _myDelegate;
    }

    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.maximumRowCountToStillUseAnimationWhileExpanding = NSIntegerMax;
    self.expandableSectionsDictionary = [NSMutableDictionary dictionary];
    self.showingSectionsDictionary = [NSMutableDictionary dictionary];
    self.downloadingSectionsDictionary = [NSMutableDictionary dictionary];
    self.animatingSectionsDictionary = [NSMutableDictionary dictionary];
    self.reloadAnimation = UITableViewRowAnimationFade;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    _storedTableHeaderView = self.tableHeaderView;
    _storedTableFooterView = self.tableFooterView;

    self.tableHeaderView = self.tableHeaderView;
    self.tableFooterView = self.tableFooterView;
}

#pragma mark - private methods

- (void)_resetExpansionStates {
    [self.expandableSectionsDictionary removeAllObjects];
    [self.showingSectionsDictionary removeAllObjects];
    [self.downloadingSectionsDictionary removeAllObjects];
}

- (void)downloadDataInSection:(NSInteger)section {
    (self.downloadingSectionsDictionary)[@(section)] = @YES;
    [self.myDelegate tableView:self downloadDataForExpandableSection:section];
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]]
                withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - instance methods

- (BOOL)canExpandSection:(NSUInteger)section {
    return [self.expandableSectionsDictionary[@(section)] boolValue];
}

- (void)reloadDataAndResetExpansionStates:(BOOL)resetFlag {
    if (resetFlag) {
        [self _resetExpansionStates];
    }

    if (self.onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty) {
        if ([self numberOfSections] > 0) {
            if ([super tableFooterView] != self.storedTableFooterView) {
                [super setTableFooterView:self.storedTableFooterView];
            }
            if ([super tableHeaderView] != self.storedTableHeaderView) {
                [super setTableHeaderView:self.storedTableHeaderView];
            }
        }
    } else {
        if ([super tableFooterView] != self.storedTableFooterView) {
            [super setTableFooterView:self.storedTableFooterView];
        }
        if ([super tableHeaderView] != self.storedTableHeaderView) {
            [super setTableHeaderView:self.storedTableHeaderView];
        }
    }

    [super reloadData];
}

- (void)cancelDownloadInSection:(NSInteger)section {
    self.downloadingSectionsDictionary[@(section)] = @NO;
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]]
                withRowAnimation:UITableViewRowAnimationNone];
}

- (void)expandSection:(NSInteger)section animated:(BOOL)animated {
    NSNumber *key = @(section);
    if ([self.showingSectionsDictionary[key] boolValue]) {
        // section is already showing, return
        return;
    }

    [self deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] animated:NO];

    if ([self.myDataSource tableView:self needsToDownloadDataForExpandableSection:section]) {
        // data is still not ready to be displayed, return
        [self downloadDataInSection:section];
        return;
    }

    if ([self.myDelegate respondsToSelector:@selector(tableView:willExpandSection:animated:)]) {
        [self.myDelegate tableView:self willExpandSection:section animated:animated];
    }

    self.animatingSectionsDictionary[key] = @YES;

    // remove the download state
    self.downloadingSectionsDictionary[key] = @NO;

    // update the showing state
    self.showingSectionsDictionary[key] = @YES;

    NSInteger newRowCount = [self.myDataSource tableView:self numberOfRowsInSection:section];
    // now do the animation magic to insert the new cells
    if (animated && newRowCount <= self.maximumRowCountToStillUseAnimationWhileExpanding) {
        [self beginUpdates];

        UITableViewCell<UIExpandingTableViewCell> *cell = (UITableViewCell<UIExpandingTableViewCell> *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        cell.loading = NO;
        [cell setExpansionStyle:UIExpansionStyleExpanded animated:YES];

        NSMutableArray *insertArray = [NSMutableArray array];
        for (int i = 1; i < newRowCount; i++) {
            [insertArray addObject:[NSIndexPath indexPathForRow:i inSection:section] ];
        }

        [self insertRowsAtIndexPaths:insertArray withRowAnimation:self.reloadAnimation];

        [self endUpdates];
    } else {
        [self reloadDataAndResetExpansionStates:NO];
    }

    [self.animatingSectionsDictionary removeObjectForKey:@(section)];

    void(^completionBlock)(void) = ^{
        if ([self respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self scrollViewDidScroll:self];
        }

        if ([self.myDelegate respondsToSelector:@selector(tableView:didExpandSection:animated:)]) {
            [self.myDelegate tableView:self didExpandSection:section animated:animated];
        }
    };

    if (animated) {
        [CATransaction setCompletionBlock:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)collapseSection:(NSInteger)section animated:(BOOL)animated {
    NSNumber *key = @(section);
    if (![self.showingSectionsDictionary[key] boolValue]) {
        // section is not showing, return
        return;
    }

    if ([self.myDelegate respondsToSelector:@selector(tableView:willCollapseSection:animated:)]) {
        [self.myDelegate tableView:self willCollapseSection:section animated:animated];
    }

    [self deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] animated:NO];

    self.animatingSectionsDictionary[key] = @YES;

    // update the showing state
    self.showingSectionsDictionary[key] = @NO;

    NSInteger newRowCount = [self.myDataSource tableView:self numberOfRowsInSection:section];
    // now do the animation magic to delete the new cells
    if (animated && newRowCount <= self.maximumRowCountToStillUseAnimationWhileExpanding) {
        [self beginUpdates];

        UITableViewCell<UIExpandingTableViewCell> *cell = (UITableViewCell<UIExpandingTableViewCell> *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        cell.loading = NO;
        [cell setExpansionStyle:UIExpansionStyleCollapsed animated:YES];

        NSMutableArray *deleteArray = [NSMutableArray array];
        for (int i = 1; i < newRowCount; i++) {
            [deleteArray addObject:[NSIndexPath indexPathForRow:i inSection:section] ];
        }

        [self deleteRowsAtIndexPaths:deleteArray withRowAnimation:self.reloadAnimation];

        [self endUpdates];
    } else {
        [self reloadDataAndResetExpansionStates:NO];
    }

    [self.animatingSectionsDictionary removeObjectForKey:@(section)];

    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                atScrollPosition:UITableViewScrollPositionTop
                        animated:animated];

    void(^completionBlock)(void) = ^{
        if ([self respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self scrollViewDidScroll:self];
        }

        if ([self.myDelegate respondsToSelector:@selector(tableView:didCollapseSection:animated:)]) {
            [self.myDelegate tableView:self didCollapseSection:section animated:animated];
        }
    };

    if (animated) {
        [CATransaction setCompletionBlock:completionBlock];
    } else {
        completionBlock();
    }
}

- (BOOL)isSectionExpanded:(NSInteger)section {
    NSNumber *key = @(section);
    return [self.showingSectionsDictionary[key] boolValue];
}

#pragma mark - super implementation

- (void)reloadData {
    [self reloadDataAndResetExpansionStates:YES];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    NSUInteger indexCount = self.numberOfSections;
    
    NSUInteger currentIndex = sections.firstIndex;
    NSInteger currentShift = 1;
    while (currentIndex != NSNotFound) {
        NSUInteger nextIndex = [sections indexGreaterThanIndex:currentIndex];
        
        if (nextIndex == NSNotFound) {
            nextIndex = indexCount;
        }

        for (NSInteger i = currentIndex + 1; i < nextIndex; i++) {
            NSUInteger newIndex = i - currentShift;
            self.expandableSectionsDictionary[@(newIndex)] = @([self.expandableSectionsDictionary[@(i)] boolValue]);
            self.showingSectionsDictionary[@(newIndex)] = @([self.showingSectionsDictionary[@(i)] boolValue]);
            self.downloadingSectionsDictionary[@(newIndex)] = @([self.downloadingSectionsDictionary[@(i)] boolValue]);
            self.animatingSectionsDictionary[@(newIndex)] = @([self.animatingSectionsDictionary[@(i)] boolValue]);
        }

        currentShift++;
        currentIndex = [sections indexLessThanIndex:currentIndex];
    }

    [super deleteSections:sections withRowAnimation:animation];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *key = @(indexPath.section);
    NSNumber *value = self.animatingSectionsDictionary[key];
    if ([value boolValue]) {
        if ([self.myDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPathWhileAnimatingSection:)]) {
            [self.myDelegate tableView:self willDisplayCell:cell forRowAtIndexPathWhileAnimatingSection:indexPath];
        }
    } else {
        if ([self.myDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
            [self.myDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        }
    }
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *key = @(indexPath.section);
    if ([self.expandableSectionsDictionary[key] boolValue]) {
        // section is expandable
        if (indexPath.row == 0) {
            // expand cell got clicked
            if ([self.myDataSource tableView:self needsToDownloadDataForExpandableSection:indexPath.section]) {
                // we need to download some data first
                [self downloadDataInSection:indexPath.section];
            } else {
                if ([self.showingSectionsDictionary[key] boolValue]) {
                    [self collapseSection:indexPath.section animated:YES];
                } else {
                    [self expandSection:indexPath.section animated:YES];
                }
            }
        } else {
            if ([self.myDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [self.myDelegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] ];
            }
        }
    } else {
        if ([self.myDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.myDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *key = @(section);
    if ([self.myDataSource tableView:self canExpandSection:section]) {
        if ([self.myDataSource tableView:tableView numberOfRowsInSection:section] == 0) {
            return 0;
        }
        self.expandableSectionsDictionary[key] = @YES;

        if ([self.showingSectionsDictionary[key] boolValue]) {
            return [self.myDataSource tableView:tableView numberOfRowsInSection:section];
        } else {
            return 1;
        }
    } else {
        self.expandableSectionsDictionary[key] = @NO;
        // expanding is not supported
        return [self.myDataSource tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *key = @(indexPath.section);
    if (![self.expandableSectionsDictionary[key] boolValue]) {
        return [self.myDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        // cell is expandable
        if (indexPath.row == 0) {
            UITableViewCell<UIExpandingTableViewCell> *cell = [self.myDataSource tableView:self expandingCellForSection:indexPath.section];
            if ([self.downloadingSectionsDictionary[key] boolValue]) {
                [cell setLoading:YES];
            } else {
                [cell setLoading:NO];
                if ([self.showingSectionsDictionary[key] boolValue]) {
                    [cell setExpansionStyle:UIExpansionStyleExpanded animated:NO];
                } else {
                    [cell setExpansionStyle:UIExpansionStyleCollapsed animated:NO];
                }
            }
            return cell;
        } else {
            return [self.myDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    return nil;
}

@end

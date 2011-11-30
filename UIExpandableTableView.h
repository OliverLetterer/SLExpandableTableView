//
//  UIExpandableTableView.h
//  iGithub
//
//  Created by me on 11.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIExpandableTableView;

typedef enum {
    UIExpansionStyleCollapsed = 0,
    UIExpansionStyleExpanded
} UIExpansionStyle;

@protocol UIExpandingTableViewCell <NSObject>

- (void)setLoading:(BOOL)loading;
- (void)setExpansionStyle:(UIExpansionStyle)style animated:(BOOL)animated;

@end



@protocol UIExpandableTableViewDatasource <UITableViewDataSource>

@required
- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section;
- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section;
- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section;

@end



@protocol UIExpandableTableViewDelegate <UITableViewDelegate>

@required
- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section;

@optional
- (void)tableView:(UIExpandableTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPathWhileAnimatingSection:(NSIndexPath *)indexPath;

@end



#ifndef UIExpandableTableView_weak
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        #define UIExpandableTableView_weak weak
    #else 
        #define UIExpandableTableView_weak unsafe_unretained
    #endif
#endif

#ifndef __UIExpandableTableView_weak
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        #define __UIExpandableTableView_weak __weak
    #else 
        #define __UIExpandableTableView_weak __unsafe_unretained
    #endif
#endif



@interface UIExpandableTableView : UITableView <UITableViewDelegate, UITableViewDataSource, NSCoding> {
@private
    id<UITableViewDelegate, UIExpandableTableViewDelegate> __UIExpandableTableView_weak _myDelegate;
    id<UITableViewDataSource, UIExpandableTableViewDatasource> __UIExpandableTableView_weak _myDataSource;
    
    NSMutableDictionary *_expandableSectionsDictionary;     // will store BOOLs for each section that is expandable
    NSMutableDictionary *_showingSectionsDictionary;        // will store BOOLs for the sections state (nil: not expanded, 1: expanded)
    NSMutableDictionary *_downloadingSectionsDictionary;    // will store BOOLs for the sections state (nil: not downloading, YES: downloading)
    NSMutableDictionary *_animatingSectionsDictionary;
    
    NSInteger _maximumRowCountToStillUseAnimationWhileExpanding;
    
    BOOL _onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty;
    UIView *_storedTableHeaderView;
    UIView *_storedTableFooterView;
}

@property (nonatomic, UIExpandableTableView_weak) id<UIExpandableTableViewDelegate> delegate;

// discussion
// you wont receive any callbacks for row 0 in an expandable section anymore
@property (nonatomic, UIExpandableTableView_weak) id<UIExpandableTableViewDatasource> dataSource;

// discussion
// never use tableView.delegate/ tableView.dataSource as a getter. setDataSource will set _myDataSource, etc. so use these getters instead
@property (nonatomic, readonly, UIExpandableTableView_weak) id<UIExpandableTableViewDelegate> myDelegate;
@property (nonatomic, readonly, UIExpandableTableView_weak) id<UIExpandableTableViewDatasource> myDataSource;

@property (nonatomic, assign) NSInteger maximumRowCountToStillUseAnimationWhileExpanding;

@property (nonatomic, assign) BOOL onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty;

// call tableView:needsToDownloadDataForExpandableSection: to make sure we can expand the section, otherwise through exception
- (void)expandSection:(NSInteger)section animated:(BOOL)animated;
- (void)collapseSection:(NSInteger)section animated:(BOOL)animated;
- (void)cancelDownloadInSection:(NSInteger)section;
- (void)reloadDataAndResetExpansionStates:(BOOL)resetFlag;

- (BOOL)canExpandSection:(NSUInteger)section;
- (BOOL)isSectionExpanded:(NSInteger)section;

@end

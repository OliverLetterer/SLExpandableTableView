//
//  SLExpandableTableView.h
//  iGithub
//
//  Created by me on 11.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLExpandableTableView;

typedef enum {
    UIExpansionStyleCollapsed = 0,
    UIExpansionStyleExpanded
} UIExpansionStyle;

@protocol UIExpandingTableViewCell <NSObject>

- (void)setLoading:(BOOL)loading;
- (void)setExpansionStyle:(UIExpansionStyle)style animated:(BOOL)animated;

@end



@protocol SLExpandableTableViewDatasource <UITableViewDataSource>

@required
- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section;
- (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section;
- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section;

@end



@protocol SLExpandableTableViewDelegate <UITableViewDelegate>

@required
- (void)tableView:(SLExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section;

@optional
- (void)tableView:(SLExpandableTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPathWhileAnimatingSection:(NSIndexPath *)indexPath;

- (void)tableView:(SLExpandableTableView *)tableView willExpandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)tableView:(SLExpandableTableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated;

- (void)tableView:(SLExpandableTableView *)tableView willCollapseSection:(NSUInteger)section animated:(BOOL)animated;
- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated;

@end



#ifndef SLExpandableTableView_weak
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        #define SLExpandableTableView_weak weak
    #else 
        #define SLExpandableTableView_weak unsafe_unretained
    #endif
#endif

#ifndef __SLExpandableTableView_weak
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        #define __SLExpandableTableView_weak __weak
    #else 
        #define __SLExpandableTableView_weak __unsafe_unretained
    #endif
#endif



@interface SLExpandableTableView : UITableView <UITableViewDelegate, UITableViewDataSource> {
@private
    id<UITableViewDelegate, SLExpandableTableViewDelegate> __SLExpandableTableView_weak _myDelegate;
    id<UITableViewDataSource, SLExpandableTableViewDatasource> __SLExpandableTableView_weak _myDataSource;
    
    NSMutableDictionary *_expandableSectionsDictionary;     // will store BOOLs for each section that is expandable
    NSMutableDictionary *_showingSectionsDictionary;        // will store BOOLs for the sections state (nil: not expanded, 1: expanded)
    NSMutableDictionary *_downloadingSectionsDictionary;    // will store BOOLs for the sections state (nil: not downloading, YES: downloading)
    NSMutableDictionary *_animatingSectionsDictionary;
    
    NSInteger _maximumRowCountToStillUseAnimationWhileExpanding;
    
    BOOL _onlyDisplayHeaderAndFooterViewIfTableViewIsNotEmpty;
    UIView *_storedTableHeaderView;
    UIView *_storedTableFooterView;
}

@property (nonatomic, SLExpandableTableView_weak) id<SLExpandableTableViewDelegate> delegate;

// discussion
// you wont receive any callbacks for row 0 in an expandable section anymore
@property (nonatomic, SLExpandableTableView_weak) id<SLExpandableTableViewDatasource> dataSource;

// discussion
// never use tableView.delegate/ tableView.dataSource as a getter. setDataSource will set _myDataSource, etc. so use these getters instead
@property (nonatomic, readonly, SLExpandableTableView_weak) id<SLExpandableTableViewDelegate> myDelegate;
@property (nonatomic, readonly, SLExpandableTableView_weak) id<SLExpandableTableViewDatasource> myDataSource;

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

# SLExpandableTableView

[![CI Status](http://img.shields.io/travis/OliverLetterer/SLExpandableTableView.svg?style=flat)](https://travis-ci.org/OliverLetterer/SLExpandableTableView)
[![Version](https://img.shields.io/cocoapods/v/SLExpandableTableView.svg?style=flat)](http://cocoadocs.org/docsets/SLExpandableTableView)
[![License](https://img.shields.io/cocoapods/l/SLExpandableTableView.svg?style=flat)](http://cocoadocs.org/docsets/SLExpandableTableView)
[![Platform](https://img.shields.io/cocoapods/p/SLExpandableTableView.svg?style=flat)](http://cocoadocs.org/docsets/SLExpandableTableView)

SLExpandableTableView is a UITableView subclass that gives you easy access to expandable and collapsable sections by just implementing a few more delegate and dataSource protocols.

## How to use SLExpandableTableView

* Installation

```
pod 'SLExpandableTableView'
```

* Load the SLExpandableTableView in a UITableViewController

```objective-c
- (void)loadView
{
    self.tableView = [[SLExpandableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}
```

* Implement the **SLExpandableTableViewDatasource** protocol

```objective-c
- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section
{
    // return YES, if the section should be expandable
}

- (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section
{
    // return YES, if you need to download data to expand this section. tableView will call tableView:downloadDataForExpandableSection: for this section
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section
{
    // this cell will be displayed at IndexPath with section: section and row 0
}
```

* Implement the **SLExpandableTableViewDelegate** protocol

```objective-c
- (void)tableView:(SLExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section
{
    // download your data here
    // call [tableView expandSection:section animated:YES]; if download was successful
    // call [tableView cancelDownloadInSection:section]; if your download was NOT successful
}

- (void)tableView:(SLExpandableTableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated
{
  //...
}

- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
  //...
}

```

## Sample Screenshots
<img src="https://github.com/OliverLetterer/SLExpandableTableView/raw/master/Screenshots/1.png">
<img src="https://github.com/OliverLetterer/SLExpandableTableView/raw/master/Screenshots/2.png">

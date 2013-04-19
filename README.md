# UIExpandableTableView
UIExpandableTableView is a UITableView subclass that gives you easy access to expandable and collapsable sections by just implementing a few more delegate and dataSource protocols.

## How to use UIExpandableTableView

* Load the UIExpandableTableView in a UITableViewController

```objective-c
- (void)loadView {
    self.tableView = [[UIExpandableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}
```

* Implement the **UIExpandableTableViewDatasource** protocol

```objective-c
- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    // return YES, if the section should be expandable
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    // return YES, if you need to download data to expand this section. tableView will call tableView:downloadDataForExpandableSection: for this section
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    // this cell will be displayed at IndexPath with section: section and row 0
}
```

* Implement the **UIExpandableTableViewDelegate** protocol

```objective-c
- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    // download your data here
    // call [tableView expandSection:section animated:YES]; if download was successful
    // call [tableView cancelDownloadInSection:section]; if your download was NOT successful
}

- (void)tableView:(UIExpandableTableView *)tableView didExpandSection:(NSUInteger)section
{
  //...
}

- (void)tableView:(UIExpandableTableView *)tableView didCollapseSection:(NSUInteger)section
{
  //...
}

```

## Sample Screenshots
<img src="https://github.com/OliverLetterer/UIExpandableTableView/raw/master/Screenshots/1.png">
<img src="https://github.com/OliverLetterer/UIExpandableTableView/raw/master/Screenshots/2.png">

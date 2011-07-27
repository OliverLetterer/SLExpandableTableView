//
//  SampleViewController.h
//  UIExpandableTableViewSample
//
//  Created by me on 27.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SampleViewController : UITableViewController {
@private
    BOOL _didDownloadData;
    
    NSArray *_dataArray;
}

@end

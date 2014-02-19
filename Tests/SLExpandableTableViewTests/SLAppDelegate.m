//
//  SLAppDelegate.m
//  SLExpandableTableViewTests
//
//  Created by Oliver Letterer on 19.02.14.
//  Copyright (c) 2014 Sparrow-Labs. All rights reserved.
//

#import "SLAppDelegate.h"
#import "SLExpandableTableViewController.h"

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    SLExpandableTableViewController *viewController = [[SLExpandableTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

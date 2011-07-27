//
//  UIExpandableTableViewSampleAppDelegate.m
//  UIExpandableTableViewSample
//
//  Created by me on 27.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIExpandableTableViewSampleAppDelegate.h"
#import "SampleViewController.h"

@implementation UIExpandableTableViewSampleAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    SampleViewController *viewController = [[SampleViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end

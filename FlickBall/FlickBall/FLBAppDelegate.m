//
//  FLBAppDelegate.m
//  FlickBall
//
//  Created by teejay on 7/22/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "FLBAppDelegate.h"

@implementation FLBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[FLBViewController alloc] initWithNibName:@"FLBViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[FLBViewController alloc] initWithNibName:@"FLBViewController_iPad" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end

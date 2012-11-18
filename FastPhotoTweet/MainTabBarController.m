//
//  MainTabBarController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/22.
//

#import "MainTabBarController.h"

@implementation MainTabBarController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate {
    
    return self.selectedViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return self.selectedViewController.supportedInterfaceOrientations;
}

@end

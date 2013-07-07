//
//  BaseNavigationController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/18.
//
//

#import "BaseNavigationController.h"


@implementation BaseNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return [self.visibleViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return self.visibleViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate {
    
    return self.visibleViewController.shouldAutorotate;
}

@end

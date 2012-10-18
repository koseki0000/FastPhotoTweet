//
//  UIViewControllerAdditinons.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/16.
//
//

#import "UIViewControllerAdditinons.h"

@implementation UIViewController (SubViewRemover)

- (void)removeAllSubViews {
    
    while ( self.view.subviews.count ) {
        
        UIView *subView = self.view.subviews.lastObject;
        [subView removeFromSuperview];
        subView = nil;
    }
}

@end

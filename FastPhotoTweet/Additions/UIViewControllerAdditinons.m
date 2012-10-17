//
//  UIViewControllerAdditinons.m
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/10/16.
//
//

#import "UIViewControllerAdditinons.h"

@implementation UIViewController (SubViewRemover)

- (void)removeAllSubViews {
    
    for ( UIView *subView in self.view.subviews ) {
        
        [subView removeFromSuperview];
        subView = nil;
    }
}

@end

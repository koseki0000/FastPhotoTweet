//
//  UIViewSubViewRemover.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/16.
//
//

#import "UIViewSubViewRemover.h"

@implementation UIView (SubViewRemover)

- (void)removeAllSubViews {
    
    while ( self.subviews.count ) {
        
        UIView *subView = self.subviews.lastObject;
        [subView removeFromSuperview];
        subView = nil;
    }
}

@end

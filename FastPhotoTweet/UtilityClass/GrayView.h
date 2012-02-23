//
//  GrayView.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>

@interface GrayView : UIView {
    
    BOOL created;
    
    UIActivityIndicatorView *activityIndicator;
}

- (void)on;
- (void)onAndSetSize:(int)x y:(int)y w:(int)w h:(int)h;
- (void)createView;
- (void)off;
- (void)remove;

@end

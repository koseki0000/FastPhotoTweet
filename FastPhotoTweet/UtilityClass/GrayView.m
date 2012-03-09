//
//  GrayView.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "GrayView.h"

@implementation GrayView

- (void)on {
    self.frame = [[UIScreen mainScreen] bounds];
    [self createView];
}

- (void)onAndSetSize:(int)x y:(int)y w:(int)w h:(int)h {
    self.frame = CGRectMake(x, y, w, h);
    [self createView];
}

- (void)createView {
    
    if (!created) {
        created = YES;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        
        activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setCenter:CGPointMake(self.frame.size.width / 2, 
                                                 self.frame.size.height / 2)];
        [self addSubview:activityIndicator];
    }
    
    [activityIndicator startAnimating];
    self.userInteractionEnabled = NO;
}

- (void)off {
    [activityIndicator stopAnimating];
    self.userInteractionEnabled = YES;
    self.frame = CGRectZero;
}

- (void)remove {
    created = NO;
    [self removeFromSuperview];
}

- (void)dealloc {
    [super dealloc];
}

@end

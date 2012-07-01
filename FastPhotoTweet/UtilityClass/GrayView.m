//
//  GrayView.m
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import "GrayView.h"

@implementation GrayView

- (void)on {
    
    //NSLog(@"GrayView On");
    
    self.frame = [[UIScreen mainScreen] bounds];
    [self createView];
}

- (void)onAndSetSize:(int)x y:(int)y w:(int)w h:(int)h {
    
    //NSLog(@"GrayView OnAndSetSize");
    
    self.frame = CGRectMake(x, y, w, h);
    [self createView];
}

- (void)createView {
        
    count++;
    
    if ( !created ) {
        
        created = YES;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        
        activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setCenter:CGPointMake(self.frame.size.width / 2, 
                                                 self.frame.size.height / 2)];
        [self addSubview:activityIndicator];
    }
    
    [activityIndicator startAnimating];
}

- (void)off {
    
    //NSLog(@"GrayView Off");
    
    count--;
    
    if ( count <= 0 ) {
        
        [activityIndicator stopAnimating];
        self.frame = CGRectZero;
    }
}

- (void)remove {
    
    //NSLog(@"GrayView Remove");
    
    count = 0;
    
    created = NO;
    [self removeFromSuperview];
}

- (void)dealloc {
    
    [super dealloc];
}

@end

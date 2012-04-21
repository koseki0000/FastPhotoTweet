//
//  ActivityIndicator.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/11/10.
//

#import "ActivityIndicator.h"

@implementation ActivityIndicator

+ (void)visible:(BOOL)visible {
    
    if ( visible ) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    }else {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }
}

@end

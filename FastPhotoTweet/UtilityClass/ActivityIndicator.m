//
//  ActivityIndicator.m
//  UtilityClass
//
//  Created by @peace3884 on 11/11/10.
//

#import "ActivityIndicator.h"

@implementation ActivityIndicator

+ (void)visible:(BOOL)visible {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        if ( visible ) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
        }else {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        }
    });
}

+ (void)on {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
}

+ (void)off {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

@end

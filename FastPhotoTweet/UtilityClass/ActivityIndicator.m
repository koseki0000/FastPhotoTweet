//
//  ActivityIndicator.m
//  UtilityClass
//
//  Created by @peace3884 on 11/11/10.
//

#import "ActivityIndicator.h"

@implementation ActivityIndicator

+ (void)visible:(BOOL)visible {
    
    visible ? [self on] : [self off];
}

+ (void)on {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+ (void)off {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end

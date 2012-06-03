//
//  AmazonAffiliateCutter.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/02.
//

#import "AmazonAffiliateCutter.h"

@implementation AmazonAffiliateCutter

+ (NSString *)string:(NSString *)string {

    //NSLog(@"Original: %@", string);
    
    NSError *error = nil;
    
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"/[-_a-zA-Z0-9]+-22/?" 
                                                                                options:0 
                                                                                  error:&error];
        
        string = [regexp stringByReplacingMatchesInString:string
                                                  options:0
                                                    range:NSMakeRange(0, string.length)
                                             withTemplate:@"/-22/"];

    //NSLog(@"Affiliate Cutted: %@", string);
    
    return string;
}

@end

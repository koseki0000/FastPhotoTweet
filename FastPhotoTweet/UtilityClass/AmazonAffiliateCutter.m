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
    NSString *template = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(/|\\?tag=)[-_a-zA-Z0-9]+-22/?" 
                                                                            options:0 
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:string 
                                                     options:0 
                                                       range:NSMakeRange(0, string.length)];
    
    if ( match.numberOfRanges != 0 ) {
        
        NSString *matchString = [string substringWithRange:match.range];
        
        if ( [matchString hasPrefix:@"/"] ) {
            
            template = @"/-22/";
            
        }else {
            
            template = @"?tag=-22";
        }
    }
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:template];
    
    //NSLog(@"Affiliate Cutted: %@", string);
    
    return string;
}

@end

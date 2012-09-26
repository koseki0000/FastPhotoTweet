//
//  AmazonAffiliateCutter.m
//  UtilityClass
//
//  Created by @peace3884 on 12/06/02.
//

#import "AmazonAffiliateCutter.h"

@implementation AmazonAffiliateCutter

//AmazonのアフィリエイトURL
//https?://(www\\.)?amazon\\.co\\.jp/((exec/obidos|o)/ASIN|dp|gp/product)/[A-Z0-9]{10}.*(/|[\\?&]tag=)[-_a-zA-Z0-9]+-22/?
//にマッチするURLを渡すとアフィリエイトを無効化したURLを返す
+ (NSString *)string:(NSString *)string {

    NSError *error = nil;
    NSString *template = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(/|[\\?&]tag=)[-_a-zA-Z0-9]+-22/?" 
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
            
            if ( [matchString hasPrefix:@"?"] ) {
            
                template = @"?tag=-22";
                
            }else {
                
                template = @"";
            }
        }
    }
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:template];
    
    return string;
}

@end

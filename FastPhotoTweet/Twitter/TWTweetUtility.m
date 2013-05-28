//
//  TWTweetUtility.m
//

#import "TWTweetUtility.h"
#import "TWParser.h"
#import "NSString+Calculator.h"

@implementation TWTweetUtility

+ (NSString *)replaceCharacterReference:(NSString *)text {
    
//    NSLog(@"%s", __func__);
    
    if ( text != nil ) {
     
        NSMutableString *replacedText = [NSMutableString stringWithString:text];
        [replacedText replaceOccurrencesOfString:@"["
                                      withString:@"［"
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        [replacedText replaceOccurrencesOfString:@"]"
                                      withString:@"］"
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        [replacedText replaceOccurrencesOfString:@"&gt;"
                                      withString:@">"
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        [replacedText replaceOccurrencesOfString:@"&lt;"
                                      withString:@"<"
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        [replacedText replaceOccurrencesOfString:@"&amp;"
                                      withString:@"&"
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        [replacedText replaceOccurrencesOfString:@"　"
                                      withString:@" "
                                         options:0
                                           range:NSMakeRange(0,
                                                             [replacedText length])];
        
        return [NSString stringWithString:replacedText];
        
    } else {
        
        return @"";
    }
}

+ (NSString *)openTco:(NSString *)text fromEntities:(TWTweetEntities *)entities {
    
//    NSLog(@"%s", __func__);
    
    if ( [entities.urls count] == 0 ) return text;
    
    NSMutableString *replacedText = [NSMutableString stringWithString:text];
    
    for ( NSDictionary *url in entities.urls ) {
        
        NSString *tcoURL = url[@"url"];
        NSString *expandedURL = @"";
        
        if ( url[@"media_url_https"] == nil ) {
            
            expandedURL = url[@"expanded_url"];
            
        } else {
            
            expandedURL = url[@"media_url_https"];
        }
        
        [replacedText replaceOccurrencesOfString:tcoURL
                              withString:expandedURL
                                 options:0
                                   range:NSMakeRange(0,
                                                     [replacedText length])];
    }
    
    return [NSString stringWithString:replacedText];
}

@end

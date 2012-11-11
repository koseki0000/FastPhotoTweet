//
//  ADBlock.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/16.
//

#import "ADBlock.h"

#define BLOCK_PATTERN @".+\\.adlantis\\.jp|.+\\.i-mobile\\.co\\.jp|i\\.adimg\\.net|ad\\.yieldmanager\\.com|adserver\\.twitpic\\.com|googleads\\.g\\.doubleclick\\.net|j\\.amoad\\.com|microad\\.jp|ad\\.pitta\\.ne\\.jp|facebook\\.com/plugins/comments\\.php|j\\.adserving\\.jp|adroute\\.focas\\.jp"

@implementation ADBlock

+ (BOOL)check:(NSString *)url {
    
    BOOL result = NO;
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:BLOCK_PATTERN
                                                                            options:0
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:url
                                                     options:0
                                                       range:NSMakeRange( 0, url.length )];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            //NSLog(@"Blocked: %@", url);
            result = YES;
        }
    }
    
    return result;
}

@end

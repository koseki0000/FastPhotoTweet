//
//  GoogleSearch.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/01.
//

#import "CreateSearchURL.h"

@implementation CreateSearchURL

+ (NSString *)google:(NSString *)searchWord {
    
    NSString *searchURL = @"http://www.google.co.jp/search?q=";
    
    return [NSString stringWithFormat:@"%@%@", searchURL, [CreateSearchURL encodeWord:searchWord]];
}

+ (NSString *)twilog:(NSString *)screenName searchWord:(NSString *)searchWord {
    
    NSString *searchURL = [NSString stringWithFormat:@"http://twilog.org/tweets.cgi?id=%@&word=%@", 
                           screenName, 
                           [CreateSearchURL encodeWord:searchWord]];
    
    return searchURL;
}

+ (NSString *)encodeWord:(NSString *)word {
    
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)word,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingShiftJIS) autorelease];
}

@end

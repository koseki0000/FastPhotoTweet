//
//  GoogleSearch.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/01.
//

#import "CreateSearchURL.h"

@implementation CreateSearchURL

+ (NSString *)google:(NSString *)word {
    
    NSString *searchURL = @"http://www.google.co.jp/search?q=";
    NSString *encodedSearchWord = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                      (CFStringRef)word,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingShiftJIS) autorelease];
    
    return [NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord];
}

+ (NSString *)twilog:(NSString *)screenName searchWord:(NSString *)searchWord {
    
    NSString *searchURL = [NSString stringWithFormat:@"http://twilog.org/tweets.cgi?id=%@&word=%@", 
                           screenName, 
                           [((NSString *)CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault, 
                                                                                 (CFStringRef)searchWord, 
                                                                                 NULL, 
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                 kCFStringEncodingUTF8)) autorelease]];
    
    return searchURL;
}

@end

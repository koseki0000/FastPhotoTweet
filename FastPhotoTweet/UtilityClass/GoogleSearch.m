//
//  GoogleSearch.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/01.
//

#import "GoogleSearch.h"

@implementation GoogleSearch

+ (NSString *)createUrl:(NSString *)word {
    
    NSString *searchURL = @"http://www.google.co.jp/search?q=";
    NSString *encodedSearchWord = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                      (CFStringRef)word,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingShiftJIS);
    [encodedSearchWord autorelease];
    
    return [NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord];
}

@end

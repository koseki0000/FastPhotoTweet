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
    
    return [NSString stringWithFormat:@"%@%@", searchURL, [CreateSearchURL encodeWord:searchWord encoding:kCFStringEncodingUTF8]];
}

+ (NSString *)twilog:(NSString *)screenName searchWord:(NSString *)searchWord {
    
    NSString *searchURL = [NSString stringWithFormat:@"http://twilog.org/%@/search?word=%@&ao=a",
                           screenName, 
                           [CreateSearchURL encodeWord:searchWord encoding:kCFStringEncodingUTF8]];
    
    return searchURL;
}

+ (NSString *)encodeWord:(NSString *)word encoding:(int)encoding {
    
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)word,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                encoding) autorelease];
}

@end

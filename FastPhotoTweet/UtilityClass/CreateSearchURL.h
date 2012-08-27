//
//  GoogleSearch.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/01.
//

#import <Foundation/Foundation.h>

@interface CreateSearchURL : NSObject

+ (NSString *)google:(NSString *)searchWord;
+ (NSString *)twilog:(NSString *)screenName searchWord:(NSString *)searchWord;

+ (NSString *)encodeWord:(NSString *)word encoding:(int)encoding;

@end

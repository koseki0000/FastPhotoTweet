//
//  GoogleSearch.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/01.
//

#import <Foundation/Foundation.h>

@interface CreateSearchURL : NSObject

+ (NSString *)google:(NSString *)word;
+ (NSString *)twilog:(NSString *)screenName searchWord:(NSString *)searchWord;

@end

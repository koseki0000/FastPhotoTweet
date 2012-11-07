//
//  NSString+RegularExpression.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/07.
//

#import <Foundation/Foundation.h>

@interface NSString (RegularExpression)

- (BOOL)boolWithRegExp:(NSString *)regExpPattern;

- (NSString *)strWithRegExp:(NSString *)regExpPattern;
- (NSMutableString *)mStrWithRegExp:(NSString *)regExpPattern;

- (NSArray *)arrayWithRegExp:(NSString *)regExpPattern;
- (NSMutableArray *)mArrayWithRegExp:(NSString *)regExpPattern;
- (NSMutableArray *)urls;
- (NSMutableArray *)twitterIds;

- (NSString *)replaceStrWithRegExp:(NSString *)regExpPattern
                        targetWord:(NSString *)targetWord;
- (NSString *)replaceMStrWithRegExp:(NSString *)regExpPattern
                         targetWord:(NSString *)targetWord;

@end

//
//  NSString+RegularExpression.h
//

#import <Foundation/Foundation.h>

@interface NSString (RegularExpression)

- (BOOL)boolWithRegExp:(NSString *)regExpPattern;

- (NSString *)stringWithRegExp:(NSString *)regExpPattern;
- (NSMutableString *)mutableStringWithRegExp:(NSString *)regExpPattern;

- (NSArray *)arrayWithRegExp:(NSString *)regExpPattern;
- (NSMutableArray *)mutableArrayWithRegExp:(NSString *)regExpPattern;
- (NSMutableArray *)URLs;
- (NSArray *)URLRanges;
- (NSMutableArray *)twitterIDs;

- (NSString *)replaceStringWithRegExp:(NSString *)regExpPattern
                        targetWord:(NSString *)targetWord;
- (NSString *)replaceMutableStringWithRegExp:(NSString *)regExpPattern
                         targetWord:(NSString *)targetWord;

@end

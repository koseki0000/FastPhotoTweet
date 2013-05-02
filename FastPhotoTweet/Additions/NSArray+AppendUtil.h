//
//  NSArray+AppendUtil.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+XPath.h"

@interface NSArray (NSArrayAppendUtil)

- (id)appendToTop:(id)unitArray returnMutable:(BOOL)returnMutable;
- (id)appendToBottom:(id)unitArray returnMutable:(BOOL)returnMutable;

- (id)appendOnlyNewToTop:(id)unitArray returnMutable:(BOOL)returnMutable;
- (id)appendOnlyNewToBottom:(id)unitArray returnMutable:(BOOL)returnMutable;

- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath separator:(NSString *)separator returnMutable:(BOOL)returnMutable;
- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath returnMutable:(BOOL)returnMutable;

- (id)appendOnlyNewTweetToTop:(id)tweetDictionariesArray returnMutable:(BOOL)returnMutable;

+ (BOOL)checkClass:(id)object;

@end

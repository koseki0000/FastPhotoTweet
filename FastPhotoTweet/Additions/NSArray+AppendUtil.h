//
//  NSArray+AppendUtil.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/01.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArrayAppendUtil)

- (id)appendToTop:(id)unitArray returnMutable:(BOOL)returnMutable;
- (id)appendToBottom:(id)unitArray returnMutable:(BOOL)returnMutable;

- (id)appendOnlyNewToTop:(id)unitArray returnMutable:(BOOL)returnMutable;
- (id)appendOnlyNewToBottom:(id)unitArray returnMutable:(BOOL)returnMutable;

+ (BOOL)checkClass:(id)object;

@end

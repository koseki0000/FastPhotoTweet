//
//  NSString+WordCollect.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/07.
//

#import <Foundation/Foundation.h>

@interface NSString (WordCollect)

- (NSString *)replaceWord:(NSString *)replaceWord
             replacedWord:(NSString *)replacedWord;
- (NSMutableString *)replaceMutableWord:(NSString *)replaceWord
              replacedWord:(NSString *)replacedWord;

- (NSString *)deleteWord:(NSString *)deleteWord;
- (NSMutableString *)deleteMutableWord:(NSString *)deleteWord;
- (NSString *)deleteWhiteSpace;

@end

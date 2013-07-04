//
//  NSString+WordCollect.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/07.
//

#import "NSString+WordCollect.h"

@implementation NSString (WordCollect)

#pragma mark - Replace

- (NSString *)replaceWord:(NSString *)replaceWord
             replacedWord:(NSString *)replacedWord {

    return [NSString stringWithString:[self replaceMutableWord:replaceWord replacedWord:replacedWord]];
}

- (NSMutableString *)replaceMutableWord:(NSString *)replaceWord
                           replacedWord:(NSString *)replacedWord {
    
    if ( replaceWord == nil ||
         replacedWord == nil ) {
        
        return [NSMutableString stringWithString:self];
    }
    
    NSMutableString *tempString = [NSMutableString stringWithString:self];
    [tempString replaceOccurrencesOfString:replaceWord
                                withString:replacedWord
                                   options:0
                                     range:NSMakeRange(0, tempString.length)];
    return tempString;
}

#pragma mark - Delete

- (NSString *)deleteWord:(NSString *)deleteWord {
    
    return [NSString stringWithString:[self deleteMutableWord:deleteWord]];
}

- (NSMutableString *)deleteMutableWord:(NSString *)deleteWord {
    
    NSMutableString *tempString = [NSMutableString stringWithString:self];
    [tempString replaceOccurrencesOfString:deleteWord
                                withString:@""
                                   options:0
                                     range:NSMakeRange(0, tempString.length)];
    return tempString;
}

- (NSString *)deleteWhiteSpace {
    
    NSString *tempString = [NSString stringWithString:self];
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s⠀]+"
                                                                            options:0
                                                                              error:nil];
    
    tempString = [regexp stringByReplacingMatchesInString:tempString
                                                  options:0
                                                    range:NSMakeRange(0, tempString.length)
                                             withTemplate:@""];

    regexp = [NSRegularExpression regularExpressionWithPattern:@"[\\s⠀]+$"
                                                       options:0
                                                         error:nil];
    
    tempString = [regexp stringByReplacingMatchesInString:tempString
                                                  options:0
                                                    range:NSMakeRange(0, tempString.length)
                                             withTemplate:@""];
    
    return [self isKindOfClass:[NSMutableString class]] ? [NSMutableString stringWithString:tempString] : [NSString stringWithString:tempString];
}

@end

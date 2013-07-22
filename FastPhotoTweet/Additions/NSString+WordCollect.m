//
//  NSString+WordCollect.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/07.
//

#import "NSString+WordCollect.h"
#import "NSString+RegularExpression.h"
#import "HankakuKana.h"

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

- (NSString *)changeRandomCharSize {
    
    NSMutableString *resultString = [NSMutableString string];
    NSUInteger limit = [self length];
    NSArray *URLRanges = [self URLRanges];
    NSUInteger currentRangeIndex = 0;
    NSRange currentRange;
    if ( [URLRanges count] != 0 ) {
        
        currentRange = [URLRanges[currentRangeIndex] rangeValue];
    }
    
    for ( NSUInteger charIndex = 0; charIndex < limit; charIndex++ ) {
        
        NSString *currentChar = [self substringWithRange:NSMakeRange(charIndex, 1)];
        if ( URLRanges != nil &&
            [URLRanges count] != 0 ) {
            
            //URLがある
            if ( charIndex >= currentRange.location &&
                 charIndex < currentRange.location + currentRange.length ) {
                
                //URLの範囲内
                [resultString appendString:currentChar];
                continue;
                
            } else if ( charIndex >= currentRange.location &&
                        charIndex == currentRange.location + currentRange.length + 1 ) {
                
                //URLの次の文字
                currentRangeIndex++;
                if ( [URLRanges count] > currentRangeIndex ) {
                    
                    //まだURLがある
                    currentRange = [URLRanges[currentRangeIndex] rangeValue];
                    
                } else {
                    
                    //もうURLがない
                    URLRanges = nil;
                }
            }
        }
        
        if ( arc4random()%2 ) {
            
            currentChar = [currentChar fullToHalfAlphanumeric];
            
        } else {
            
            currentChar = [currentChar halfToFullAlphanumeric];
        }
        
        [resultString appendString:currentChar];
    }
    
    return resultString;
}

- (NSString *)halfToFullAlphanumeric {
    
    if ( self.length == 0 ) {
        
        return self;
    }
    
    NSArray *wideDigitArray = @[@"０", @"１", @"２", @"３", @"４", @"５", @"６", @"７", @"８", @"９", @"Ａ", @"Ｂ", @"Ｃ", @"Ｄ", @"Ｅ", @"Ｆ", @"Ｇ", @"Ｈ", @"Ｉ", @"Ｊ", @"Ｋ", @"Ｌ", @"Ｍ", @"Ｎ", @"Ｏ", @"Ｐ", @"Ｑ", @"Ｒ", @"Ｓ", @"Ｔ", @"Ｕ", @"Ｖ", @"Ｗ", @"Ｘ", @"Ｙ", @"Ｚ", @"ａ", @"ｂ", @"ｃ", @"ｄ", @"ｅ", @"ｆ", @"ｇ", @"ｈ", @"ｉ", @"ｊ", @"ｋ", @"ｌ", @"ｍ", @"ｎ", @"ｏ", @"ｐ", @"ｑ", @"ｒ", @"ｓ", @"ｔ", @"ｕ", @"ｖ", @"ｗ", @"ｘ", @"ｙ", @"ｚ"];
    
    NSArray *narrowDigitArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
    
    NSMutableString *convertedString = [self mutableCopy];
    NSUInteger count = wideDigitArray.count;
    
    for (NSInteger i = 0; i < count; i++) {
        
        [convertedString replaceOccurrencesOfString:[narrowDigitArray objectAtIndex:i]
                                         withString:[wideDigitArray objectAtIndex:i]
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [convertedString length])];
    }
    
    return convertedString;
}

- (NSString *)fullToHalfAlphanumeric {
    
    if ( self.length == 0 ) {
        
        return self;
    }
    
    NSArray *wideDigitArray = @[@"０", @"１", @"２", @"３", @"４", @"５", @"６", @"７", @"８", @"９", @"Ａ", @"Ｂ", @"Ｃ", @"Ｄ", @"Ｅ", @"Ｆ", @"Ｇ", @"Ｈ", @"Ｉ", @"Ｊ", @"Ｋ", @"Ｌ", @"Ｍ", @"Ｎ", @"Ｏ", @"Ｐ", @"Ｑ", @"Ｒ", @"Ｓ", @"Ｔ", @"Ｕ", @"Ｖ", @"Ｗ", @"Ｘ", @"Ｙ", @"Ｚ", @"ａ", @"ｂ", @"ｃ", @"ｄ", @"ｅ", @"ｆ", @"ｇ", @"ｈ", @"ｉ", @"ｊ", @"ｋ", @"ｌ", @"ｍ", @"ｎ", @"ｏ", @"ｐ", @"ｑ", @"ｒ", @"ｓ", @"ｔ", @"ｕ", @"ｖ", @"ｗ", @"ｘ", @"ｙ", @"ｚ"];
    
    NSArray *narrowDigitArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
    
    NSMutableString *convertedString = [self mutableCopy];
    NSUInteger count = wideDigitArray.count;
    
    for (NSInteger i = 0; i < count; i++) {
        
        [convertedString replaceOccurrencesOfString:[wideDigitArray objectAtIndex:i]
                                         withString:[narrowDigitArray objectAtIndex:i]
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [convertedString length])];
    }
    
    return convertedString;
}

@end

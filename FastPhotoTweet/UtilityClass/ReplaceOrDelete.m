//
//  StringWordReplaceOrDelete.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ReplaceOrDelete.h"

@implementation ReplaceOrDelete

+ (NSString *)replaceWordReturnStr:(id)string 
                       replaceWord:(NSString *)replaceWord 
                      replacedWord:(NSString *)replacedWord {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
    @try {
        
        [mString replaceOccurrencesOfString:replaceWord 
                                 withString:replacedWord 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
    }@catch (NSException *e) {
        
        return [NSString stringWithString:string];
    }
    
    return [NSString stringWithString:mString];
}

+ (NSString *)deleteWordReturnStr:(id)string 
                       deleteWord:(NSString *)deleteWord {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
    @try {
        
        [mString replaceOccurrencesOfString:deleteWord 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
    }@catch (NSException *e) {
        
        return [NSString stringWithString:string];
    }
    
    return [NSString stringWithString:mString];
}

+ (NSMutableString *)replaceWordReturnMStr:(id)string 
                               replaceWord:(NSString *)replaceWord 
                              replacedWord:(NSString *)replacedWord {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
    @try {
        
        [mString replaceOccurrencesOfString:replaceWord 
                                 withString:replacedWord 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
    }@catch (NSException *e) {
        
        return [NSString stringWithString:string];
    }
    
    return mString;
}

+ (NSMutableString *)deleteWordReturnMStr:(id)string 
                               deleteWord:(NSString *)deleteWord {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
    @try {
        
        [mString replaceOccurrencesOfString:deleteWord 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
    }@catch (NSException *e) {
        
        return [NSString stringWithString:string];
    }
    
    return mString;
}

@end

//
//  StringWordReplaceOrDelete.h
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import <Foundation/Foundation.h>

@interface ReplaceOrDelete : NSObject

+ (NSString *)replaceWordReturnStr:(id)string 
                      replaceWord:(NSString *)replaceWord 
                     replacedWord:(NSString *)replacedWord;

+ (NSString *)deleteWordReturnStr:(id)string 
                      deleteWord:(NSString *)deleteWord;

+ (NSMutableString *)replaceWordReturnMStr:(id)string 
                              replaceWord:(NSString *)replaceWord 
                             replacedWord:(NSString *)replacedWord;

+ (NSMutableString *)deleteWordReturnMStr:(id)string 
                              deleteWord:(NSString *)deleteWord;;

@end

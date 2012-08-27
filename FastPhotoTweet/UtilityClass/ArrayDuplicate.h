//
//  ArrayDuplicate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <Foundation/Foundation.h>

@interface ArrayDuplicate : NSObject

+ (NSMutableArray *)checkArray:(NSMutableArray *)array;
+ (NSMutableArray *)checkArrayInNumber:(NSMutableArray *)array;
+ (NSMutableArray *)arrayInDictionaryForKey:(NSMutableArray *)array key:(NSString *)key;

@end

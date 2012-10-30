//
//  NSDictionary+DataExtraction.h
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DataExtraction)

- (NSInteger)integerForKey:(id)aKey;
- (NSUInteger)uintegerForKey:(id)aKey;
- (double)doubleForKey:(id)aKey;
- (float)floatForKey:(id)aKey;
- (long)longForKey:(id)aKey;
- (unsigned long)uLongForKey:(id)aKey;
- (long long)longLongForKey:(id)aKey;
- (unsigned long long)uLongLongForKey:(id)aKey;
- (BOOL)boolForKey:(id)aKey;

- (NSNumber *)numberForKey:(id)aKey;

- (NSString *)stringForKey:(id)aKey;
- (NSMutableString *)mutableStringForKey:(id)aKey;

- (NSArray *)arrayForKey:(id)aKey;
- (NSMutableArray *)mutableArrayForKey:(id)aKey;

- (NSDictionary *)dictionaryForKey:(id)aKey;
- (NSMutableDictionary *)mutableDictionaryForKey:(id)aKey;

- (NSData *)dataForKey:(id)aKey;
- (NSMutableData *)mutableDataForKey:(id)aKey;

- (NSSet *)setForKey:(id)aKey;
- (NSMutableSet *)mutableSetForKey:(id)aKey;

- (UIImage *)imageForKey:(id)aKey;
- (CGImageRef *)cgImageForKey:(id)aKey;

@end

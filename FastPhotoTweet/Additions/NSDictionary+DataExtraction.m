//
//  NSDictionary+DataExtraction.m
//

#import "NSDictionary+DataExtraction.h"

@implementation NSDictionary (DataExtraction)

- (NSInteger)integerForKey:(id)aKey {
    return [[self objectForKey:aKey] integerValue];
}

- (NSUInteger)uintegerForKey:(id)aKey {
    return [[self objectForKey:aKey] unsignedIntegerValue];
}

- (double)doubleForKey:(id)aKey {
    return [[self objectForKey:aKey] doubleValue];
}

- (float)floatForKey:(id)aKey {
    return [[self objectForKey:aKey] floatValue];
}

- (long)longForKey:(id)aKey {
    return [[self objectForKey:aKey] longValue];
}

- (unsigned long)uLongForKey:(id)aKey {
    return [[self objectForKey:aKey] unsignedLongValue];
}

- (long long)longLongForKey:(id)aKey {
    return [[self objectForKey:aKey] longLongValue];
}

- (unsigned long long)uLongLongForKey:(id)aKey {
    return [[self objectForKey:aKey] unsignedLongLongValue];
}

- (NSNumber *)numberForKey:(id)aKey {
    return @([[self objectForKey:aKey] integerValue]);
}

- (BOOL)boolForKey:(id)aKey {
    return [[self objectForKey:aKey] boolValue];
}

- (NSString *)stringForKey:(id)aKey {
    return [NSString stringWithString:[self objectForKey:aKey]];
}

- (NSMutableString *)mutableStringForKey:(id)aKey {
    return [NSMutableString stringWithString:[self objectForKey:aKey]];
}

- (NSArray *)arrayForKey:(id)aKey {
    return [NSArray arrayWithArray:[self objectForKey:aKey]];
}

- (NSMutableArray *)mutableArrayForKey:(id)aKey {
    return [NSMutableArray arrayWithArray:[self objectForKey:aKey]];
}

- (NSDictionary *)dictionaryForKey:(id)aKey {
    return [NSDictionary dictionaryWithDictionary:[self objectForKey:aKey]];
}

- (NSMutableDictionary *)mutableDictionaryForKey:(id)aKey {
    return [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:aKey]];
}

- (NSData *)dataForKey:(id)aKey {
    return [NSKeyedArchiver archivedDataWithRootObject:[self objectForKey:aKey]];
}

- (NSMutableData *)mutableDataForKey:(id)aKey {
    return [NSMutableData dataWithData:[NSKeyedArchiver archivedDataWithRootObject:[self objectForKey:aKey]]];
}

- (NSSet *)setForKey:(id)aKey {
    return [NSSet setWithSet:[self objectForKey:aKey]];
}

- (NSMutableSet *)mutableSetForKey:(id)aKey {
    return [NSMutableSet setWithSet:[self objectForKey:aKey]];
}

- (UIImage *)imageForKey:(id)aKey {
    return (UIImage *)[self objectForKey:aKey];
}

- (CGImageRef *)cgImageForKey:(id)aKey {
    return (CGImageRef *)[(UIImage *)[self objectForKey:aKey] CGImage];
}

@end

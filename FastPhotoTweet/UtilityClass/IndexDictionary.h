//
//  IndexDictionary.h
//

#import <Foundation/Foundation.h>

@interface IndexDictionary : NSObject {

    BOOL _sort;
    NSMutableDictionary *_items;
    NSArray *_sortedIndexKeys;

    NSUInteger _iteratorIndex;
}

//Initialize
- (id)initWithDictionary:(NSDictionary *)dictionary sort:(BOOL)sort;
- (id)initWithArray:(NSArray *)array sort:(BOOL)sort;

//Sort
- (NSArray *)itemKeys;
- (NSArray *)objects;
- (void)resetIndex;

//GetObject
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(NSString *)key;
- (NSString *)keyAtIndex:(NSUInteger)index;

//AddObject
- (void)addObject:(id)object forKey:(NSString *)key;
- (void)addObjects:(NSArray *)objects forKeys:(NSArray *)keys;
- (void)addDictionary:(id)dictionary;

//ReplaceObject
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)replaceObjects:(NSArray *)objects forKeys:(NSArray *)keys;

//RemoveObject
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

//KeyRename
- (void)keyRenameForKey:(NSString *)key newKeyName:(NSString *)newKeyName;
- (void)keyRenameAtIndex:(NSUInteger)index newKeyName:(NSString *)newKeyName;

//Iterator
- (id)firstObject;
- (id)lastObject;
- (id)currentObject;
- (id)nextObject;
- (id)beforeObject;
- (void)setIteratorIndex:(NSUInteger)index;
- (NSUInteger)currentIteratorIndex;
- (BOOL)isExistNextItem;
- (void)resetIterator;

//GetValue
- (NSUInteger)count;
- (NSArray *)allKeys;
- (NSArray *)allValues;
- (NSString *)description;
- (NSString *)debugDescription;

//DebugLog
- (void)logOutputAllKey;
- (void)logOutputAllObject;
- (void)logOutputAll;

@end

//
//  IndexDictionary.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/05.
//

#import "IndexDictionary.h"

@implementation IndexDictionary

#pragma mark - Initialize

- (id)initWithDictionary:(NSDictionary *)dictionary sort:(BOOL)sort {
    
    self = [super init];
    
    if ( dictionary == nil ) dictionary = @{};
    
    if ( self ) {
        
        _sort = sort;
        _items = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        [self resetIndex];
        
        _iteratorIndex = 0;
    }
    
    return self;
}

- (id)initWithArray:(NSArray *)array sort:(BOOL)sort {
    
    self = [super init];
    
    if ( self ) {
        
        _sort = sort;
        _items = [NSMutableDictionary dictionary];
        _iteratorIndex = 0;
        
        if ( array != nil && array.count != 0 ) {
            
            for ( int i = 0; i < array.count; i++ ) {
                
                [_items setObject:[array objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
        [self resetIndex];
    }
    
    return self;
}

#pragma mark - Sort

- (NSArray *)itemKeys {
    
    if ( _sort ) {
        
        return [[_items allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
    }else {
        
        return [_items allKeys];
    }
}

- (NSArray *)objects {
    
    [self resetIndex];
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < _sortedIndexKeys.count; i++ ) {
        
        [temp addObject:[_items objectForKey:[_sortedIndexKeys objectAtIndex:i]]];
    }
    
    return [NSArray arrayWithArray:temp];
}

- (void)resetIndex {
    
    _sortedIndexKeys = [self itemKeys];
}

#pragma mark - GetObject

- (id)objectAtIndex:(NSUInteger)index {
    
    if ( _sortedIndexKeys == nil ||
        _items == nil ||
        index >= _sortedIndexKeys.count ) {
        
        return nil;
        
    }else {
        
        return [_items objectForKey:[_sortedIndexKeys objectAtIndex:index]];
    }
}

- (NSString *)keyAtIndex:(NSUInteger)index {
    
    if ( _sortedIndexKeys == nil ||
        _items == nil ||
        index >= _sortedIndexKeys.count ) {
        
        return nil;
        
    }else {
        
        return [_sortedIndexKeys objectAtIndex:index];
    }
}

- (id)objectForKey:(NSString *)key {
    
    if ( key == nil ) return nil;
    
    return [_items objectForKey:key];
}

#pragma mark - AddObject

- (void)addObject:(id)object {
    
    if ( object == nil ) return;
    
    [_items setObject:object forKey:[NSString stringWithFormat:@"%d", _items.count + 1]];
    [self resetIndex];
}

- (void)addObject:(id)object forKey:(NSString *)key {
    
    if ( object == nil ||
        key == nil ||
        [key isEqualToString:@""] ) return;
    
    if ( [ _items objectForKey:key] == nil ) {
        
        [_items setObject:object forKey:key];
        [self resetIndex];
    }
}

- (void)addObjects:(NSArray *)objects {
    
    if ( objects == nil || objects.count == 0 ) return;
    
    for (int i = 0; i < objects.count; i++ ) {
        
        [_items setObject:[objects objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", _items.count + 1]];
    }
    
    [self resetIndex];
}

- (void)addObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    
    if (( objects != nil && keys != nil ) &&
        objects.count == keys.count ) {
        
        for (int i = 0; i < objects.count; i++ ) {
            
            if ( [ _items objectForKey:[keys objectAtIndex:i]] == nil ) {
                
                [_items setObject:[objects objectAtIndex:i] forKey:[keys objectAtIndex:i]];
            }
        }
        
        [self resetIndex];
    }
}

- (void)addDictionary:(id)dictionary {
    
    if ( dictionary != nil ) {
        
        if ( [dictionary isKindOfClass:[NSDictionary class]] ||
            [dictionary isKindOfClass:[NSMutableDictionary class]] ) {
            
            NSDictionary *temp = [NSDictionary dictionaryWithDictionary:dictionary];
            
            if ( temp.count != 0 ) {
                
                NSArray *keys = [temp allKeys];
                NSArray *values = [temp allValues];
                
                for (int i = 0; i < keys.count; i++ ) {
                    
                    [_items setObject:[values objectAtIndex:i] forKey:[keys objectAtIndex:i]];
                }
                
                [self resetIndex];
            }
        }
    }
}

#pragma mark - ChangeObject

- (void)changeObjectWithObject:(id)object {
    
    [self removeAllObjects];
    [self addObject:object];
}

- (void)changeObjectWithArray:(NSArray *)array {
    
    [self removeAllObjects];
    [self addObjects:array];
}

- (void)changeObjectWithDictionary:(NSDictionary *)dictionary {
    
    [self removeAllObjects];
    [self addDictionary:dictionary];
}

#pragma mark - ReplaceObject

- (void)replaceObject:(id)object forKey:(NSString *)key {
    
    if ( object == nil ||
        key == nil ||
        [key isEqualToString:@""] ) return;
    
    [_items setObject:object forKey:key];
    [self resetIndex];
}

- (void)replaceObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    
    if (( objects != nil && keys != nil ) &&
        objects.count == keys.count ) {
        
        for (int i = 0; i < objects.count; i++ ) {
            
            [_items setObject:[objects objectAtIndex:i] forKey:[keys objectAtIndex:i]];
        }
        
        [self resetIndex];
    }
}

#pragma mark - RemoveObject

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    [_items removeObjectForKey:[_sortedIndexKeys objectAtIndex:index]];
    [self resetIndex];
}

- (void)removeObjectForKey:(NSString *)key {
    
    if ( key == nil ) return;
    
    [_items removeObjectForKey:key];
    [self resetIndex];
}

- (void)removeAllObjects {
    
    [_items removeAllObjects];
    [self resetIndex];
}

#pragma mark - KeyRename

- (void)keyRenameForKey:(NSString *)key newKeyName:(NSString *)newKeyName {
    
    if (( key != nil && [key isEqualToString:@""] ) &&
        ( newKeyName != nil && [newKeyName isEqualToString:@""] ) &&
        [self objectForKey:key] != nil ) {
        
        id object = [self objectForKey:key];
        [self removeObjectForKey:key];
        [self addObject:object forKey:newKeyName];
    }
}

- (void)keyRenameAtIndex:(NSUInteger)index newKeyName:(NSString *)newKeyName {
    
    if (( newKeyName != nil && [newKeyName isEqualToString:@""] ) &&
        index >= _sortedIndexKeys.count &&
        [self objectAtIndex:index] != nil ) {
        
        id object = [self objectAtIndex:index];
        [self removeObjectAtIndex:index];
        [self addObject:object forKey:newKeyName];
    }
}

#pragma mark - Iterator

- (id)firstObject {
    
    if ( _sortedIndexKeys != nil &&
        _sortedIndexKeys.count != 0 ) {
        
        _iteratorIndex = 0;
        return [self objectAtIndex:_iteratorIndex];
        
    }else {
        
        return nil;
    }
}

- (id)lastObject {
    
    if ( _sortedIndexKeys != nil &&
        _sortedIndexKeys.count != 0 ) {
        
        _iteratorIndex = _sortedIndexKeys.count - 1;
        return [self objectAtIndex:_iteratorIndex];
        
    }else {
        
        return nil;
    }
}

- (id)currentObject {
    
    return [self objectAtIndex:_iteratorIndex];
}

- (id)nextObject {
    
    if ( [self objectAtIndex:_iteratorIndex + 1] != nil ) {
        
        _iteratorIndex++;
        return [self objectAtIndex:_iteratorIndex];
        
    }else {
        
        return nil;
    }
}

- (id)beforeObject {
    
    if ( _iteratorIndex - 1 != 0 ) {
        
        _iteratorIndex--;
        return [self objectAtIndex:_iteratorIndex];
        
    }else {
        
        return nil;
    }
}

- (void)setIteratorIndex:(NSUInteger)index {
    
    _iteratorIndex = index;
}

- (NSUInteger)currentIteratorIndex {
    
    return _iteratorIndex;
}

- (void)incrementIndex {
    
    _iteratorIndex++;
}

- (void)decrementIndex {
    
    _iteratorIndex--;
}

- (BOOL)isExistNextItem {
    
    return [self objectAtIndex:_iteratorIndex + 1] ? YES : NO;
}

- (void)resetIterator {
    
    _iteratorIndex = 0;
}

- (BOOL)iterator {
    
    return [self isExistNextItem];
}

#pragma mark - GetValue

- (NSUInteger)count {
    
    return _sortedIndexKeys.count;
}

- (NSArray *)allKeys {
    
    return [self itemKeys];
}

- (NSArray *)allValues {
    
    return [self objects];
}

- (NSString *)description {
    
    return _items.description;
}

- (NSString *)debugDescription {
    
    return _items.debugDescription;
}

#pragma mark - Search

- (NSArray *)keySearchResultWithSearchWord:(NSString *)searchWord {
    
    NSMutableArray *resultKeys = [NSMutableArray array];
    
    if ( searchWord == nil ||
        ( ![searchWord isKindOfClass:[NSString class]] && ![searchWord isKindOfClass:[NSMutableString class]] )) {
        
        return resultKeys;
    }
    
    for ( NSString *item in self.allKeys ) {
        
        if ( [item rangeOfString:searchWord].location != NSNotFound ) {
            
            [resultKeys addObject:item];
        }
    }
    
    return resultKeys;
}

- (NSArray *)valueSearchResultWithSearchWord:(NSString *)searchWord {
    
    NSMutableArray *resultValues = [NSMutableArray array];
    
    if ( searchWord == nil ||
        ( ![searchWord isKindOfClass:[NSString class]] && ![searchWord isKindOfClass:[NSMutableString class]] )) {
        
        return resultValues;
    }
    
    for ( id item in self.allValues ) {
        
        if (( [item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSMutableString class]] ) &&
            [item rangeOfString:searchWord].location != NSNotFound ) {
            
            [resultValues addObject:item];
        }
    }
    
    return resultValues;
}

- (IndexDictionary *)keySearchResultWithSearchWord:(NSString *)searchWord sort:(BOOL)sort {
    
    NSMutableArray *result = [NSMutableArray array];
    
    if ( searchWord == nil ||
        [searchWord isEqualToString:@""] ) {
        
        IndexDictionary *resultObjects = [[[IndexDictionary alloc] initWithArray:result sort:sort] autorelease];
        
        return resultObjects;
    }
    
    for ( id item in self.allKeys ) {
        
        if ( [item rangeOfString:searchWord].location != NSNotFound ) {
            
            [result addObject:item];
        }
    }
    
    IndexDictionary *resultObjects = [[[IndexDictionary alloc] initWithArray:result sort:sort] autorelease];
    
    return resultObjects;
}

- (IndexDictionary *)valueSearchResultWithSearchWord:(NSString *)searchWord sort:(BOOL)sort {
    
    NSMutableArray *result = [NSMutableArray array];
    
    if ( searchWord == nil ||
        [searchWord isEqualToString:@""] ) {
        
        IndexDictionary *resultObjects = [[[IndexDictionary alloc] initWithArray:result sort:sort] autorelease];
        
        return resultObjects;
    }
    
    for ( id item in self.allValues ) {
        
        if (( [item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSMutableString class]] ) &&
            [item rangeOfString:searchWord].location != NSNotFound ) {
            
            [result addObject:item];
        }
    }
    
    IndexDictionary *resultObjects = [[[IndexDictionary alloc] initWithArray:result sort:sort] autorelease];
    
    return resultObjects;
}

#pragma mark - DebugLog

- (void)logOutputAllKey {
    
    NSLog(@"logOutputAllKey[%d]", _sortedIndexKeys.count);
    
    for ( NSString *key in _sortedIndexKeys ) {
        
        NSLog(@"%@", key);
    }
}

- (void)logOutputAllObject {
    
    NSLog(@"logOutputAllObject[%d]", _sortedIndexKeys.count);
    
    for ( NSString *key in _sortedIndexKeys ) {
        
        NSLog(@"%@", [[self objectForKey:key] debugDescription]);
    }
}

- (void)logOutputAll {
    
    NSLog(@"logOutputAll[%d]", _sortedIndexKeys.count);
    
    for ( NSString *key in _sortedIndexKeys ) {
        
        NSLog(@"%@ : %@", key, [[self objectForKey:key] debugDescription]);
    }
}

#pragma mark - MemoryManagement

- (void)dealloc {
    
    NSLog(@"IndexDictionary dealloc");
    
    [_items removeAllObjects];
    _items = nil;
    _sortedIndexKeys = nil;
    
    [super dealloc];
}

@end

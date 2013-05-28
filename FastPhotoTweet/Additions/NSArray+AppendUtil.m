//
//  NSArray+AppendUtil.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import "NSArray+AppendUtil.h"
#import "TWTweet.h"

@implementation NSArray (NSArrayAppendUtil)

- (id)appendToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [unitArray isNil] ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
            int i = 0;
            for ( id item in unitArray ) {
                
                [wTempArray insertObject:item
                                 atIndex:i];
                i++;
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendToBottom:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [unitArray isNil] ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            for ( id item in unitArray ) {
                
                [wTempArray addObject:item];
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [unitArray isNil] ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        __block __weak id wself = self;
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            int i = 0;
            for ( id item in unitArray ) {
                
                BOOL notHave = YES;
                for ( id myItem in wself ) {
                    
                    if ( [myItem isEqual:item] ) {
                     
                        notHave = NO;
                        break;
                    }
                }
                
                if ( notHave ) {
                    
                    [wTempArray insertObject:item atIndex:i];
                    i++;
                }
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToBottom:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [unitArray isNil] ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        __block __weak id wself = self;
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            for ( id item in unitArray ) {
                
                BOOL notHave = YES;
                for ( id myItem in wself ) {
                    
                    if ( [myItem isEqual:item] ) {
                        
                        notHave = NO;
                        break;
                    }
                }
                
                if ( notHave ) [wTempArray addObject:item];
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath separator:(NSString *)separator returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [dictionariesArray isNil] ) return self;
    
    if ( [NSArray checkClass:dictionariesArray] ) {
        
        if ( [(NSArray *)dictionariesArray isEmpty] ) return self;
        
        __block __weak id wself = self;
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            BOOL isOnlyDictionary = YES;
            for ( id item in dictionariesArray ) {
                
                if (!( [item isKindOfClass:[NSDictionary class]] ||
                       [item isKindOfClass:[NSMutableDictionary class]] )) {
                    
                    isOnlyDictionary = NO;
                    break;
                }
            }
            
            for ( id item in wself ) {
                
                if (!( [item isKindOfClass:[NSDictionary class]] ||
                       [item isKindOfClass:[NSMutableDictionary class]] )) {
                    
                    isOnlyDictionary = NO;
                    break;
                }
            }
            
            if ( isOnlyDictionary ) {
             
                int i = 0;
                for ( NSDictionary *item in dictionariesArray ) {
                    
                    BOOL notHave = YES;
                    for ( NSDictionary *myItem in wself ) {
                        
                        id targetMyItem = [myItem objectForXPath:xpath separator:separator];
                        id targetItem = [item objectForXPath:xpath separator:separator];
                        
                        if ( [targetMyItem isNotEmpty] &&
                             [targetItem isNotEmpty] ) {
                            
                            if ( [targetMyItem isEqual:targetItem] ) {
                                
                                notHave = NO;
                                break;
                            }
                        }
                    }
                    
                    if ( notHave ) {
                        
                        [wTempArray insertObject:item atIndex:i];
                        i++;
                    }
                }
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath returnMutable:(BOOL)returnMutable {
    
    return [self appendOnlyNewToTop:dictionariesArray
                           forXPath:xpath
                          separator:@"/"
                      returnMutable:returnMutable];
}

- (id)appendOnlyNewTweetToTop:(id)tweetDictionariesArray returnMutable:(BOOL)returnMutable {
    
    if ( [self isNil] || [tweetDictionariesArray isNil] ) return self;
    
    if ( [NSArray checkClass:tweetDictionariesArray] ) {
        
        if ( [(NSArray *)tweetDictionariesArray isEmpty] ) return self;
        
        __block __weak id wself = self;
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        __block __weak NSMutableArray *wTempArray = tempArray;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            int i = 0;
            for ( TWTweet *tweet in tweetDictionariesArray ) {
                
                BOOL notHave = YES;
                for ( TWTweet *myTweew in wself ) {
                    
                    NSString *myTweetID = myTweew.tweetID;
                    NSString *tweetID = tweet.tweetID;
                    
                    if ( [myTweetID isNotEmpty] &&
                         [tweetID isNotEmpty] ) {
                        
                        if ( [myTweetID isEqualToString:tweetID] ) {
                        
                            notHave = NO;
                            break;
                        }
                    }
                }
                
                if ( notHave ) {
                    
                    [wTempArray insertObject:tweet atIndex:i];
                    i++;
                }
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

+ (BOOL)checkClass:(id)object {
    
    if ( [object isKindOfClass:[NSArray class]] ||
         [object isKindOfClass:[NSMutableArray class]] ) {
        
        return YES;
    }
    
    return NO;
}

@end
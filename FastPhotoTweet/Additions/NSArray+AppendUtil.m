//
//  NSArray+AppendUtil.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/01.
//

#import "NSArray+AppendUtil.h"

@implementation NSArray (NSArrayAppendUtil)

- (id)appendToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( self == nil || unitArray == nil ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( ((NSArray *)unitArray).count == 0 ) return self;
        
        __block NSMutableArray *tempArray = nil;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
            tempArray = [NSMutableArray arrayWithArray:self];
            
            int i = 0;
            for ( id item in unitArray ) {
                
                [tempArray insertObject:item atIndex:i];
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
    
    if ( self == nil || unitArray == nil ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( ((NSArray *)unitArray).count == 0 ) return self;
        
        __block NSMutableArray *tempArray = nil;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            tempArray = [NSMutableArray arrayWithArray:self];
            
            for ( id item in unitArray ) {
                
                [tempArray addObject:item];
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( self == nil || unitArray == nil ) return self;
      
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( ((NSArray *)unitArray).count == 0 ) return self;
        
        __block NSMutableArray *tempArray = nil;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            tempArray = [NSMutableArray arrayWithArray:self];
            
            int i = 0;
            for ( id item in unitArray ) {
                
                BOOL notHave = YES;
                for ( id myItem in self ) {
                    
                    if ( [myItem isEqual:item] ) {
                     
                        notHave = NO;
                        break;
                    }
                }
                
                if ( notHave ) {
                    
                    [tempArray insertObject:item atIndex:i];
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
    
    if ( self == nil || unitArray == nil ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( ((NSArray *)unitArray).count == 0 ) return self;
        
        __block NSMutableArray *tempArray = nil;
        
        dispatch_queue_t semaphoreQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(semaphoreQueue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            tempArray = [NSMutableArray arrayWithArray:self];
            
            for ( id item in unitArray ) {
                
                BOOL notHave = YES;
                for ( id myItem in self ) {
                    
                    if ( [myItem isEqual:item] ) {
                        
                        notHave = NO;
                        break;
                    }
                }
                
                if ( notHave ) [tempArray addObject:item];
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

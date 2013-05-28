//
//  NSObject+EmptyCheck.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import "NSObject+EmptyCheck.h"

@implementation NSObject (EmptyCheck)

//return
//YES is Empty
//NO  is Not Empty
- (BOOL)isEmpty {
    
    BOOL result = YES;
    
    if ( self != nil ) {
        
        result = NO;
        
        if ( ![self isKindOfClass:[NSNull class]] ) {
            
            if ( [self isKindOfClass:[NSString class]] ) {
                
                result = ((NSString *)self).length == 0;
                
            }else if ( [self isKindOfClass:[NSMutableString class]] ) {
                
                result = ((NSMutableString *)self).length == 0;
                
            }else if ( [self isKindOfClass:[NSArray class]] ) {
                
                result = ((NSArray *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSMutableArray class]] ) {
                
                result = ((NSMutableArray *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSSet class]] ) {
                
                result = ((NSSet *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSMutableSet class]] ) {
                
                result = ((NSMutableSet *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSDictionary class]] ) {
                
                result = ((NSDictionary *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSMutableDictionary class]] ) {

                result = ((NSMutableDictionary *)self).count == 0;
                
            }else if ( [self isKindOfClass:[NSData class]] ) {
                
                result = ((NSData *)self).length == 0;
                
            }else if ( [self isKindOfClass:[NSMutableData class]] ) {
                
                result = ((NSMutableData *)self).length == 0;
                
            }else if ( [self isKindOfClass:[NSURL class]] ) {

                result = ((NSURL *)self).absoluteString.length == 0;
            }
            
        } else {
            
            result = YES;
        }
    }
    
    return result;
}

//return
//YES is Not Empty
//NO  is Empty
- (BOOL)isNotEmpty {
    
    BOOL result = NO;
    
    if ( self != nil ) {
        
        if ( ![self isKindOfClass:[NSNull class]] ) {
            
            if ( [self isKindOfClass:[NSString class]] ) {
                
                result = ((NSString *)self).length != 0;
                
            }else if ( [self isKindOfClass:[NSMutableString class]] ) {
                
                result = ((NSMutableString *)self).length != 0;
                
            }else if ( [self isKindOfClass:[NSArray class]] ) {
                
                result = ((NSArray *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSMutableArray class]] ) {
                
                result = ((NSMutableArray *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSSet class]] ) {
                
                result = ((NSSet *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSMutableSet class]] ) {
                
                result = ((NSMutableSet *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSDictionary class]] ) {
                
                result = ((NSDictionary *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSMutableDictionary class]] ) {
                
                result = ((NSMutableDictionary *)self).count != 0;
                
            }else if ( [self isKindOfClass:[NSData class]] ) {
                
                result = ((NSData *)self).length != 0;
                
            }else if ( [self isKindOfClass:[NSMutableData class]] ) {
                
                result = ((NSMutableData *)self).length != 0;
                
            }else if ( [self isKindOfClass:[NSURL class]] ) {
                
                result = ((NSURL *)self).absoluteString.length != 0;
            }
        }
    }
    
    return result;
}

- (BOOL)isNil {
    
    return self == nil ? YES : NO;
}

- (BOOL)isNotNil {
    
    return self != nil ? YES : NO;
}

@end

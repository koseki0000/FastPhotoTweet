//
//  NSObject+EmptyCheck.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/01.
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
                
                if ( [(NSString *)self isEqualToString:@""] ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSMutableString class]] ) {
                
                if ( [(NSMutableString *)self isEqualToString:@""] ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSArray class]] ) {
                
                if ( ((NSArray *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSMutableArray class]] ) {
                
                if ( ((NSMutableArray *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSSet class]] ) {
                
                if ( ((NSSet *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSMutableSet class]] ) {
                
                if ( ((NSMutableSet *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSDictionary class]] ) {
                
                if ( ((NSDictionary *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSMutableDictionary class]] ) {
                
                if ( ((NSMutableDictionary *)self).count == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSData class]] ) {
                
                if ( ((NSData *)self).length == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSMutableData class]] ) {
                
                if ( ((NSMutableData *)self).length == 0 ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
                
            }else if ( [self isKindOfClass:[NSURL class]] ) {
                
                if ( [((NSURL *)self).absoluteString isEqualToString:@""] ) {
                    
                    result = YES;
                    
                }else {
                    
                    result = NO;
                }
            }
            
        }else {
            
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
                
                if ( ![(NSString *)self isEqualToString:@""] ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSMutableString class]] ) {
                
                if ( ![(NSMutableString *)self isEqualToString:@""] ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSArray class]] ) {
                
                if ( ((NSArray *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSMutableArray class]] ) {
                
                if ( ((NSMutableArray *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSSet class]] ) {
                
                if ( ((NSSet *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSMutableSet class]] ) {
                
                if ( ((NSMutableSet *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSDictionary class]] ) {
                
                if ( ((NSDictionary *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSMutableDictionary class]] ) {
                
                if ( ((NSMutableDictionary *)self).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSData class]] ) {
                
                if ( ((NSData *)self).length != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSMutableData class]] ) {
                
                if ( ((NSMutableData *)self).length != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [self isKindOfClass:[NSURL class]] ) {
                
                if ( ![((NSURL *)self).absoluteString isEqualToString:@""] ) {
                    
                    result = YES;
                }
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

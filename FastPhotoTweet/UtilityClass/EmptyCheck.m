//
//  EmptyCheck.m
//  UtilityClass
//
//  Created by @peace3884 on 12/03/05.
//

#import "EmptyCheck.h"

@implementation EmptyCheck

//YES:  空でない
//NO:   空
+ (BOOL)check:(id)obj {
    
    @autoreleasepool {
        
        BOOL result = NO;
        
        ////NSLog(@"obj: %@", obj);
        
        //オブジェクトが空かチェック
        if ( obj != nil || obj != [NSNull null] ) {
            
            //空ではない
            if ( [obj isKindOfClass:[NSString class]] ) {
                
                if ( ![((NSString *)obj) isEqualToString:@""] ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSMutableString class]] ) {
                
                if ( ![((NSMutableString *)obj) isEqualToString:@""] ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSArray class]] ) {
                
                if ( ((NSArray *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSMutableArray class]] ) {
                
                if ( ((NSMutableArray *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSSet class]] ) {
                
                if ( ((NSSet *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSMutableSet class]] ) {
                
                if ( ((NSMutableSet *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSDictionary class]] ) {
                
                if ( ((NSDictionary *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSMutableDictionary class]] ) {
                
                if ( ((NSMutableDictionary *)obj).count != 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSData class]] ) {
                
                if ( ((NSData *)obj).length > 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSMutableData class]] ) {
                
                if ( ((NSMutableData *)obj).length > 0 ) {
                    
                    result = YES;
                }
                
            }else if ( [obj isKindOfClass:[NSURL class]] ) {
                
                if ( ![((NSURL *)obj).absoluteString isEqualToString:@""] ) {
                    
                    result = YES;
                }
                
            }else {
                
                //わからん
                //NSLog(@"Unknown Obj type");
            }
            
        }else {
            
            //NSLog(@"Obj is nil");
        }
        
        return result;
    }
}

+ (BOOL)string:(NSString *)string {
    
    BOOL result = NO;
    
    if ( string != nil && ![string isEqualToString:@""] && string.length != 0 ) {
        
        result = YES;
    }
    
    return  result;
}

@end

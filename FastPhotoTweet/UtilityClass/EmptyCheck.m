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
    
    BOOL result = NO;
    
    ////NSLog(@"obj: %@", obj);
    
    //オブジェクトが空かチェック
    if ( obj != nil ) {
        
        //空ではない
        if ( [obj isKindOfClass:[NSString class]] ) {
            
            NSString *str = (NSString *)obj;
            if ( ![str isEqualToString:@""] ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSMutableString class]] ) { 
            
            NSMutableString *mStr = (NSMutableString *)obj;
            if ( ![mStr isEqualToString:@""] ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSArray class]] ) { 
            
            NSArray *array = (NSArray *)obj;
            if ( array.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSMutableArray class]] ) { 
            
            NSMutableArray *mArray = (NSMutableArray *)obj;
            if ( mArray.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSSet class]] ) { 
            
            NSSet *set = (NSSet *)obj;
            if ( set.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSMutableSet class]] ) { 
            
            NSMutableSet *mSet = (NSMutableSet *)obj;
            
            if ( mSet.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSDictionary class]] ) { 
            
            NSDictionary *dic = (NSDictionary *)obj;
            if ( dic.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSMutableDictionary class]] ) { 
            
            NSMutableDictionary *mDic = (NSMutableDictionary *)obj;
            if ( mDic.count != 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSData class]] ) { 
            
            NSData *data = (NSData *)obj;
            if ( data.length > 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSMutableData class]] ) { 
            
            NSMutableData *mData = (NSMutableData *)obj;
            if ( mData.length > 0 ) {
                
                result = YES;
            }
            
        }else if ( [obj isKindOfClass:[NSURL class]] ) { 
            
            NSURL *url = (NSURL *)obj;
            if ( ![url.absoluteString isEqualToString:@""] ) {
                
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

@end

//
//  EmptyCheck.m
//  FastPhotoTweet
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
                
                //NSLog(@"NSString is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSString is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSMutableString class]] ) { 
            
            NSMutableString *mStr = (NSMutableString *)obj;
            if ( ![mStr isEqualToString:@""] ) {
                
                //NSLog(@"NSMutableString is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSMutableString is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSArray class]] ) { 
            
            NSArray *array = (NSArray *)obj;
            if ( array.count != 0 ) {
                
                //NSLog(@"NSArray is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSArray is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSMutableArray class]] ) { 
            
            NSMutableArray *mArray = (NSMutableArray *)obj;
            if ( mArray.count != 0 ) {
                
                //NSLog(@"NSMutableArray is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSMutableArray is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSSet class]] ) { 
            
            NSSet *set = (NSSet *)obj;
            if ( set.count != 0 ) {
                
                //NSLog(@"NSSet is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSSet is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSMutableSet class]] ) { 
            
            NSMutableSet *mSet = (NSMutableSet *)obj;
            
            if ( mSet.count != 0 ) {
                
                //NSLog(@"NSMutableSet is not empty");
                result = YES;
            }else {
                
                //NSLog(@"NSMutableSet is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSDictionary class]] ) { 
            
            NSDictionary *dic = (NSDictionary *)obj;
            if ( dic.count != 0 ) {
                
                //NSLog(@"NSDictionary is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSDictionary is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSMutableDictionary class]] ) { 
            
            NSMutableDictionary *mDic = (NSMutableDictionary *)obj;
            if ( mDic.count != 0 ) {
                
                //NSLog(@"NSMutableDictionary is not empty");
                result = YES;
                
            }else {
                
                //NSLog(@"NSMutableDictionary is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSData class]] ) { 
            
            NSData *data = (NSData *)obj;
            if ( data.length > 0 ) {
                
                //NSLog(@"NSData is not empty");
                result = YES;
            }else {
                
                //NSLog(@"NSData is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSMutableData class]] ) { 
            
            NSMutableData *mData = (NSMutableData *)obj;
            if ( mData.length > 0 ) {
                
                //NSLog(@"NSMutableData is not empty");
                result = YES;
            }else {
                
                //NSLog(@"NSMutableData is empty");
            }
            
        }else if ( [obj isKindOfClass:[NSURL class]] ) { 
            
            NSURL *url = (NSURL *)obj;
            if ( ![url.absoluteString isEqualToString:@""] ) {
                
                //NSLog(@"NSURL is not empty");
                result = YES;
            }else {
                
                //NSLog(@"NSURL is empty");
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

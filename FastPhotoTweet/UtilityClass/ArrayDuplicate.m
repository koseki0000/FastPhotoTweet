//
//  ArrayDuplicate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "ArrayDuplicate.h"

@implementation ArrayDuplicate

+ (NSMutableArray *)checkArray:(NSMutableArray *)array {
    
    for ( int i = 0; i < array.count; i++ ) {
        
        NSString *currentString = [array objectAtIndex:i];
        
        int index = 0;
        for ( NSString *temp in array ) {
            
            if ( [temp isEqualToString:currentString] && index != i ) {
                
                [array removeObjectAtIndex:i];
                i--;
                break;
            }
            
            index++;
        }
    }
    
    return array;
}

+ (NSMutableArray *)arrayInDictionaryForKey:(NSMutableArray *)array key:(NSString *)key {
    
    //引数チェック
    if ( array.count == 0 || array == nil ||
        [key isEqualToString:@""] || key == nil ) return nil;
    
    BOOL find = NO;
    int index = 0;
    
    for ( int i = 0; i < array.count; i++ ) {
        
        //チェック対象
        NSDictionary *currentDictionary = [array objectAtIndex:i];
        //チェック対象が空なら次へ
        if ( currentDictionary == nil ) continue;
        //キーが存在しない場合は次へ
        if ( [currentDictionary objectForKey:key] == nil ) continue;
        
        //検索対象の全てのキー
        NSArray *keys = [currentDictionary allKeys];
        
        for ( NSString *temp in keys ) {
            
            //キーを探す
            if ( [temp isEqualToString:key] ) {
                
                //発見
                find = YES;
                break;
            }
        }
    
        if ( find ) break;
        
        index++;
    }
    
    //指定したキーの最初のものを発見、かつ発見したキーがArrayの最後のものではない
    if ( find && index != array.count ) {
        
        NSDictionary *findDic = [array objectAtIndex:index];
        
        index++;
        
        for ( int i = index; array.count; i++ ) {
            
            if ( [[[array objectAtIndex:i] objectForKey:key] isEqualToString:[findDic objectForKey:key]] ) {
                
                //重複キーを削除
                [array removeObjectAtIndex:i];
                i--;
            }
        }
    }
    
    return array;
}

@end

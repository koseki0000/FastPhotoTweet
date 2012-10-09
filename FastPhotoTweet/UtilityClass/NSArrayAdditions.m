//
//  NSArrayAdditions.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/05.
//

#import "NSArrayAdditions.h"

@implementation NSArray (ItemControl)

- (id)deleteDuplicate {
    
    //重複要素を削除する
    NSArray *fixedArray = [[[[NSSet alloc] initWithArray:[NSArray arrayWithArray:self]] autorelease] allObjects];
    
    //クラスを合わせて返す
    return [self isKindOfClass:[NSArray class]] ? fixedArray : [NSMutableArray arrayWithArray:fixedArray];
}

- (id)deleteDuplicateSequential {
    
    //可変長化する
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
    
    for ( int i = 0; i < tempArray.count; i++ ) {
        
        //現在の文字列
        id currentItem = [tempArray objectAtIndex:i];
        int index = 0;
        
        for ( id temp in tempArray ) {
            
            //配列の中身を比較し、同一かつ現在の文字列ではない場合削除する
            if ( [temp isEqual:currentItem] && index != i ) {
                
                [tempArray removeObjectAtIndex:i];
                i--;
                
                break;
            }
            
            index++;
        }
    }
    
    //クラスを合わせて返す
    return [self isKindOfClass:[NSMutableArray class]] ? tempArray : [NSArray arrayWithArray:tempArray];
}

@end

//
//  ArrayDuplicate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "ArrayDuplicate.h"

@implementation ArrayDuplicate

+ (NSMutableArray *)check:(NSMutableArray *)array {
    
    for ( int i = 0; i < array.count; i++ ) {
        
        NSString *currenString = [array objectAtIndex:i];
        
        int index = 0;
        for ( NSString *temp in array ) {
            
            if ( [temp isEqualToString:currenString] && index != i ) {
                
                [array removeObjectAtIndex:i];
                i--;
                break;
            }
            
            index++;
        }
    }
    
    return array;
}

@end

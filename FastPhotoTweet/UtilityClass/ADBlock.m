//
//  ADBlock.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/16.
//

#import "ADBlock.h"

//ブロックするURLリスト
#define BLOCK_LIST @[ @"https://static.adlantis.jp/", @"http://xid.i-mobile.co.jp/", @"http://i.adimg.net/", @"http://uuid.adlantis.jp/", @"http://ad.yieldmanager.com/", @"http://adserver.twitpic.com/", @"http://googleads.g.doubleclick.net/", @"http://j.amoad.com/", @"http://ad.adlantis.jp/" ]

@implementation ADBlock

+ (BOOL)check:(NSString *)url {
    
    BOOL result = NO;
    
    //ブロックするURLリストから順にチェック
    for ( NSString *blockUrl in BLOCK_LIST ) {
        
        //チェック対象のURLがブロックリストのURLで始まっているかチェック
        if ( [url hasPrefix:blockUrl ] ) {
            
            //条件にマッチした場合ブロックを行う
            NSLog(@"BlockPattern: %@", blockUrl);
            
            result = YES;
            break;
        }
    }
    
    return result;
}

@end

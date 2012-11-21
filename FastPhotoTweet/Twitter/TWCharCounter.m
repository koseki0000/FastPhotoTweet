//
//  TWCharCounter.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWCharCounter.h"

#define BLANK @""

@implementation TWCharCounter

//現在入力されている文字数をt.coを考慮してカウントし、残りの入力可能文字数を返す
//URLはどんな長さでも1つ20文字としてカウント
//文頭、末尾にある半角スペース･改行･タブはカウントされない
//"トップレベルドメイン - Wikipedia" http://j.mp/oPPkZx
//gTLD, sTLD, iTLD, 特殊用途についてはhttp(s)プロトコル無しでもt.co判定が行われる
+ (int)charCounter:(id)post {
    
    //自動開放プールを生成
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //id型で受け取りNSMutableStringにキャスト
    NSMutableString *postString = [NSMutableString stringWithString:post];
    
    int num = 140;
    int originalCharNum = num - postString.length;
    int urlCount = 0;
    
    @try {
        
        NSError *error = nil;
        
        //行頭スペースをカウントしない
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s]+" 
                                                                                options:0 
                                                                                  error:&error];
        
        postString = [NSMutableString stringWithString:[regexp stringByReplacingMatchesInString:postString
                                                                                        options:0
                                                                                          range:NSMakeRange(0, postString.length)
                                                                                   withTemplate:BLANK]];
        
        //文末スペースをカウントしない
        regexp = [NSRegularExpression regularExpressionWithPattern:@"[\\s]+$" 
                                                           options:0 
                                                             error:&error];
        
        postString = (NSMutableString *)[regexp stringByReplacingMatchesInString:postString
                                                                         options:0
                                                                           range:NSMakeRange(0, postString.length)
                                                                    withTemplate:BLANK];
        
        //URLカウント
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink 
                                                                       error:&error];
        
        NSArray *matches = [linkDetector matchesInString:postString 
                                                 options:0 
                                                   range:NSMakeRange(0, [postString length])];
        
        for ( int i = matches.count - 1; i >= 0; i-- ) {
        
            NSTextCheckingResult *match = [matches objectAtIndex:i];
            
            if ( [match resultType] == NSTextCheckingTypeLink ) {
                
                NSString *urlString = [postString substringWithRange:match.range];
                
                //URLを削除
                [postString replaceOccurrencesOfString:urlString 
                                            withString:BLANK 
                                                 options:0 
                                                   range:NSMakeRange( match.range.location, 
                                                                      match.range.length )];
            }
        }
        
        urlCount = matches.count;
        
        //残り入力可能文字数 = 140 - URL以外の文字数 - 行頭･末尾半角スペースの数 - URLの数 * 20
        num = num - postString.length - urlCount * 20;
        
    }@catch ( NSException *e ) {
        
        //エラーの場合は取り敢えず140 - オリジナルの文字数を返しておく
        return originalCharNum;
        
    }@finally {
        
        //自動開放プールを開放
        [pool drain];
    }
    
    //入力可能文字数を返す
    return num;
}

@end
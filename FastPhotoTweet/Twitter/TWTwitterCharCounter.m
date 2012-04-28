//
//  TWTwitterCharCounter.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWTwitterCharCounter.h"

#define URL_REGEXP @"(https?:([^\\x00-\\x20()\"<>\\x7F-\\xFF])*|([-\\w]+\\.)+(com|net|org|info|biz|name|pro|aero|coop|museum|jobs|travel|mail|cat|post|asia|mobi|tel|xxx|int|gov|edu|arpa))([^\\x00-\\x20()\"<>\\x7F-\\xFF])*"

@implementation TWTwitterCharCounter

//現在入力されている文字数をt.coを考慮してカウントし、残りの入力可能文字数を返す
//URLはどんな長さでも1つ20文字としてカウント
//文頭、末尾にある半角スペース･改行･タブはカウントされない
//"トップレベルドメイン - Wikipedia" http://j.mp/oPPkZx
//gTLD, sTLD, iTLD, 特殊用途についてはhttp(s)プロトコル無しでもt.co判定が行われる
+ (int)charCounter:(id)post {
    
    //自動開放プールを生成
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //id型で受け取りNSMutableStringにキャスト
    NSMutableString *postString = (NSMutableString *)post;
    
    int num = 140;
    int originalCharNum = num - postString.length;
    int urlCount = 0;
    NSMutableArray *urlList = [NSMutableArray array];
    
    @try {
        
        //URLを抽出する正規表現を設定
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:URL_REGEXP 
                                                                                options:0 
                                                                                  error:nil];
        
        NSArray *match = [regexp matchesInString:postString 
                                         options:0 
                                           range:NSMakeRange( 0, postString.length )];
        
        //文字列中にいくつURLがあるかチェック
        for ( NSTextCheckingResult *result in match ) {
            
            //見つかったURLを保存
            NSString *matchString = [postString substringWithRange:result.range];
            [urlList addObject:matchString];
        }
        
        urlCount = urlList.count;
        
        //NSLog(@"urlList: %@", urlList);
        
        //行頭スペースをカウントしない
        regexp = [NSRegularExpression regularExpressionWithPattern:@"^[ \n\t]+" 
                                                           options:0 
                                                             error:nil];
        
        postString = (NSMutableString *)[regexp stringByReplacingMatchesInString:postString
                                                                         options:0
                                                                           range:NSMakeRange(0, postString.length)
                                                                    withTemplate:@""];
        
        //文末スペースをカウントしない
        regexp = [NSRegularExpression regularExpressionWithPattern:@"[ \n\t]+$" 
                                                           options:0 
                                                                error:nil];
        
        postString = (NSMutableString *)[regexp stringByReplacingMatchesInString:postString
                                                                         options:0
                                                                           range:NSMakeRange(0, postString.length)
                                                                    withTemplate:@""];
        
        if ( urlList.count != 0 ) {
            
            for ( int i = 0; i < urlList.count; i++) {
                
                NSString *temp = [urlList objectAtIndex:i];
                
                if ( [temp hasPrefix:@"http"] ) {
                    
                    //オリジナルの文字列からプロトコルありURLを取り除く
                    regexp = [NSRegularExpression regularExpressionWithPattern:temp 
                                                                       options:0 
                                                                         error:nil];
                    
                    NSTextCheckingResult *matchResult = [regexp firstMatchInString:postString 
                                                                           options:0 
                                                                             range:NSMakeRange( 0, postString.length )];
                    
                    [postString replaceOccurrencesOfString:temp withString:@"" 
                                                   options:0 
                                                     range:NSMakeRange( matchResult.range.location, 
                                                                       matchResult.range.length )];
                    [urlList removeObjectAtIndex:i];
                    
                    i--;
                }
            }
        }
        
        if ( urlList.count != 0 ) {
            
            for ( NSString *temp in urlList ) {
                
                //オリジナルの文字列からプロトコルなしURLを取り除く
                regexp = [NSRegularExpression regularExpressionWithPattern:temp 
                                                                   options:0 
                                                                     error:nil];
                
                NSTextCheckingResult *matchResult = [regexp firstMatchInString:postString 
                                                                       options:0 
                                                                         range:NSMakeRange( 0, postString.length )];
                
                [postString replaceOccurrencesOfString:temp withString:@"" 
                                               options:0 
                                                 range:NSMakeRange( matchResult.range.location, 
                                                                   matchResult.range.length )];
            }
        }
        
        //URLリストを破棄
        [urlList removeAllObjects];
        
        //残り入力可能文字数 = 140 - URL以外の文字数 - 行頭･末尾半角スペースの数 - URLの数 * 20
        num = num - postString.length - urlCount * 20;
        
    }@catch ( NSException *e ) {
        
        NSLog(@"Exception: %@", e);
        
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
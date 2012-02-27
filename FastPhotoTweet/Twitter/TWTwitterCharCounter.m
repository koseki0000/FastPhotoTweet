//
//  TWTwitterCharCounter.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWTwitterCharCounter.h"

@implementation TWTwitterCharCounter

//現在入力されている文字数をt.coを考慮してカウントし、残りの入力可能文字数を返す
//URLはどんな長さでも1つ20文字としてカウント
+ (int)charCounter:(id)post {
    
    //自動開放プールを生成
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //id型で受け取りNSMutableStringにキャスト
    NSMutableString *postString = [NSMutableString stringWithString:post];
    
    int num = 140;
    int originalCharNum = postString.length;
    int urlCount = 0;
    NSMutableArray *urlList = [NSMutableArray array];
    
    @try {
        
        //URLを抽出する正規表現を設定
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"https?:([^\\x00-\\x20()\"<>\\x7F-\\xFF])*" 
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
            
            //URLの個数カウントを増やす
            urlCount++;
            
        }
        
        for ( NSString *tmp in urlList ) {
            
            //オリジナルの文字列からURLを取り除く
            [postString replaceOccurrencesOfString:tmp withString:@"" 
                                     options:0 
                                       range:NSMakeRange( 0, postString.length )];
            
        }
        
        //残り入力可能文字数 = 140 - URL以外の文字数 - URLの数 * 20
        num = num - postString.length - urlCount * 20;
        
    }@catch ( NSException *e ) {
        
        //エラーの場合は取り敢えずオリジナルの文字数を返しておく
        return originalCharNum;
        
    }@finally {
        
        //自動開放プールを開放
        [pool drain];
        
    }
    
    //入力可能文字数を返す
    return num;
}

@end

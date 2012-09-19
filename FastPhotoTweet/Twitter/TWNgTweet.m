//
//  TWNgTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

#import "TWNgTweet.h"

@implementation TWNgTweet

//・NG条件
//Word: NG対象ワード
//User: 指定ユーザーNG
//ExclusionUser: 指定ユーザーNG除外
//RegExp: 正規表現
+ (NSArray *)ngWord:(NSArray *)tweets {
    
    NSMutableArray *targets = [NSMutableArray arrayWithArray:tweets];
    
    //NSLog(@"ngWord targets.count: %d", targets.count);

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    //NG情報を読み込み
    NSArray *ngWords = [d arrayForKey:@"NGWord"];
    //NSLog(@"ngWords: %@", ngWords);
    
    //タイムラインもしくはNG設定がない場合は終了
    if ( targets.count == 0 || ngWords.count == 0 ) return [NSArray arrayWithArray:tweets];
    
    //現在の自分のアカウント名
    NSString *myAccont = [[TWGetAccount currentAccount] username];
    
    //対象Tweetのtext
    NSString *text = nil;
    
    //対象Tweetのscreen_name
    NSString *screenName = nil;
    
    //NGワード
    NSString *word = nil;
    
    //NG指定ユーザー
    NSArray *users = [NSArray array];
    
    //NG除外ユーザー
    NSArray *exclusionUsers = [NSArray array];
    
    //正規表現
    BOOL regexp = NO;
    
    //自分のTweetもNGを行う
    BOOL myTweetNG = [d boolForKey:@"MyTweetNG"];
    
    //条件にマッチしたか
    BOOL match = NO;
    
    //NG対象のインデックス
    int index = 0;
    
    //NG対象を記憶
    NSMutableArray *ngList = [NSMutableArray array];
    
    //TimelineのTweetを順次読み込む
    for ( NSDictionary *tweet in targets ) {
        
        //Tweetを読み込み
        text = [tweet objectForKey:@"text"];
        
        //NG設定を順次読み込む
        for ( NSDictionary *ngData in ngWords ) {
            
            //NG設定を読み込み
            word = [ngData objectForKey:@"Word"];
            users = [[ngData objectForKey:@"User"] componentsSeparatedByString:@","];
            exclusionUsers = [[ngData objectForKey:@"ExclusionUser"] componentsSeparatedByString:@","];
            regexp = [[ngData objectForKey:@"RegExp"] boolValue];
            match = NO;
            
            //NSLog(@"[%d:%@]%@", index, word, text);
            
            if ( ![EmptyCheck string:word] ) {
                
                //NGワードがない場合は次へ
                continue;
            }
            
            //NG対象ユーザーかNG除外ユーザーが指定されている場合
            screenName = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
            
            if ( users.count != 0 ) {
             
                BOOL notUser = NO;
                
                for ( NSString *user in users ) {
                    
                    if ( ![screenName isEqualToString:[DeleteWhiteSpace string:user]] ) {
                        
                        //指定ユーザーのTweetではない
                        notUser = YES;
                    }
                    
                    //指定ユーザーのTweetではないのでループ終了
                    if ( notUser ) break;
                }
                
                //指定ユーザーのTweetではないので次へ
                if ( notUser ) continue;
            }
            
            if ( exclusionUsers.count != 0 ) {
                
                BOOL notUser = NO;
                
                for ( NSString *exclusionUser in exclusionUsers ) {
                    
                    if ( [screenName isEqualToString:[DeleteWhiteSpace string:exclusionUser]] ) {
                        
                        //NG除外ユーザーのTweet
                        notUser = YES;
                    }
                    
                    //NG除外ユーザーのTweetなのでループ終了
                    if ( notUser ) break;
                }
                
                //NG除外ユーザーのTweetなので次へ
                if ( notUser ) continue;
            }
            
            if ( regexp ) {
                
                //正規表現を使う場合
                if ( [RegularExpression boolRegExp:text regExpPattern:word] ) match = YES;
                
            }else {

                //正規表現を使わない場合
                if ( [text rangeOfString:word].location != NSNotFound ) match = YES;
            }
            
            //NG条件にマッチしていた場合
            if ( match ) {
                
                //対象ワードが見つかった場合
                if ( !myTweetNG ) {
                    
                    //自分のTweetはNGしない場合
                    screenName = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                    
                    if ( ![screenName isEqualToString:myAccont] ) {
                        
                        //自分のTweetではない場合NG
                        //NSLog(@"[%d:%@]%@", index, word, [tweet objectForKey:@"text"]);
                        [ngList addObject:[NSNumber numberWithInt:index]];
                    }
                    
                }else {
                    
                    //自分のTweetでもNG
                    //NSLog(@"[%d:%@]%@", index, word, [tweet objectForKey:@"text"]);
                    [ngList addObject:[NSNumber numberWithInt:index]];
                }
            }
        }
        
        //インデックスを増やして次へ
        index++;
    }
    
    if ( ngList.count != 0 ) {
        
        //NSLog(@"ngList: %@", ngList);
        
        [ArrayDuplicate checkArrayInNumber:ngList];
        
        int removeIndex = 0;
        
        //NSLog(@"ngList: %@", ngList);
        
        //NGすべきものがある場合
        for ( int i = ngList.count - 1; i >= 0; i-- ) {
            
            removeIndex = [[ngList objectAtIndex:i] intValue];
            
            //NSLog(@"i: %d, targets: %d, removeIndex: %d", i, targets.count, removeIndex);
            
            if ( targets.count >= removeIndex ) {
             
                //対象Tweetを削除
                [targets removeObjectAtIndex:removeIndex];
            }
        }
    }
    
    //NSLog(@"ngWord targets.count: %d", targets.count);
    
    return [NSArray arrayWithArray:targets];
}

//・NG条件
//User: screen_name
+ (NSArray *)ngName:(NSArray *)tweets {
    
    NSMutableArray *targets = [NSMutableArray arrayWithArray:tweets];
    
    //NSLog(@"targets.count: %d", targets.count);
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    //NG情報を読み込み
    NSArray *ngNames = [d arrayForKey:@"NGName"];
    //NSLog(@"ngNames: %@", ngNames);
    
    //タイムラインもしくはNG設定がない場合は終了
    if ( targets.count == 0 || ngNames.count == 0 ) return [NSArray arrayWithArray:tweets];
    
    //NSLog(@"targets: %@", targets);
    
    //対象Tweetのscreen_name
    NSString *screenName = nil;
    
    //NG指定ユーザー
    NSString *user = nil;
    
    //NG対象のインデックス
    int index = 0;
    
    //NG対象を記憶
    NSMutableArray *ngList = [NSMutableArray array];
    
    //TimelineのTweetを順次読み込む
    for ( NSDictionary *tweet in targets ) {
        
        //Tweetを読み込み
        screenName = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
        
        //NG設定を順次読み込む
        for ( NSDictionary *ngData in ngNames ) {
            
            //NG設定を読み込み
            user = [ngData objectForKey:@"User"];
            
            if ( user == nil ) {
                
                //NGネームがない場合は次へ
                continue;
            }
            
            if ( [screenName isEqualToString:user] ) {
                
                //NGネームに一致した場合
                [ngList addObject:[NSNumber numberWithInt:index]];
            }
        }
        
        //インデックスを増やして次へ
        index++;
    }        
    
    if ( ngList.count != 0 ) {
        
        //NGすべきものがある場合
        for ( int i = ngList.count - 1; i >= 0; i-- ) {
            
            //対象Tweetを削除
            [targets removeObjectAtIndex:[[ngList objectAtIndex:i] intValue]];
        }
    }
    
    //NSLog(@"ngName targets.count: %d", targets.count);
    
    return [NSArray arrayWithArray:targets];
}

//・NG条件
//Client: クライアント名
+ (NSArray *)ngClient:(NSArray *)tweets {
    
    //NSLog(@"NGClient Start");
    
    NSMutableArray *targets = [NSMutableArray arrayWithArray:tweets];
    
    //NSLog(@"ngClient targets.count: %d", targets.count);
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    //NG情報を読み込み
    NSArray *ngClients = [d arrayForKey:@"NGClient"];
    //NSLog(@"ngClients: %@", ngClients);
    
    //タイムラインもしくはNG設定がない場合は終了
    if ( targets.count == 0 || ngClients.count == 0 ) return [NSArray arrayWithArray:tweets];
    
    //NSLog(@"targets: %@", targets);
    
    //対象TweetのClient
    NSString *client = nil;
    
    //NG指定ユーザー
    NSString *ngClient = nil;
    
    //NG対象のインデックス
    int index = 0;
    
    //NG対象を記憶
    NSMutableArray *ngList = [NSMutableArray array];
    
    //TimelineのTweetを順次読み込む
    for ( NSDictionary *tweet in targets ) {
        
        //Tweetを読み込み
        client = [TWParser client:[tweet objectForKey:@"source"]];
        
        //NG設定を順次読み込む
        for ( NSDictionary *ngData in ngClients ) {
            
            //NG設定を読み込み
            ngClient = [ngData objectForKey:@"Client"];
            
            if ( ngClient == nil ) {
                
                //NGクライアントがない場合は次へ
                continue;
            }
            
            if ( [client isEqualToString:ngClient] ) {
                
                //NGクライアントに一致した場合
                [ngList addObject:[NSNumber numberWithInt:index]];
            }
        }
        
        //インデックスを増やして次へ
        index++;
    }
    
    if ( ngList.count != 0 ) {
        
        //NGすべきものがある場合
        for ( int i = ngList.count - 1; i >= 0; i-- ) {
            
            //対象Tweetを削除
            [targets removeObjectAtIndex:[[ngList objectAtIndex:i] intValue]];
        }
    }
    
    //NSLog(@"ngClient targets.count: %d", targets.count);
    
    return [NSArray arrayWithArray:targets];
}

+ (id)ngAll:(id)tweets {
    
    BOOL isMutable = NO;
    
    //型チェック
    if ( ![tweets isKindOfClass:[NSArray class]] &&
         ![tweets isKindOfClass:[NSMutableArray class]]) {
        
        //NSArray でも NSMutableArray でもない場合
        NSLog(@"ngAll not array");
        
        return nil;
    }
    
    //可変長であるかチェック
    if ( [tweets isKindOfClass:[NSMutableArray class]] ) isMutable = YES;
    
    //NGを行う
    NSArray *tweetsArray = [NSArray arrayWithArray:tweets];
    tweetsArray = [TWNgTweet ngWord:tweetsArray];
    tweetsArray = [TWNgTweet ngName:tweetsArray];
    tweetsArray = [TWNgTweet ngClient:tweetsArray];
    
    //可変長で受け取った場合は可変長にして返す
    if ( isMutable ) tweets = [NSMutableArray arrayWithArray:tweetsArray];
    
    return tweets;
}

@end

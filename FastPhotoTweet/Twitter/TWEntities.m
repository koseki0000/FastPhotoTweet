//
//  TWEntities.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWEntities.h"

@implementation TWEntities

//TweetのDictionaryを渡すとt.coを展開した本文を返す
+ (NSString *)openTco:(NSDictionary *)tweet {
    
    //Tweetが空だった場合は空文字列を返す
    if ( tweet == nil ) return @"";
    
    NSMutableString *text = nil;
    
    if ( [tweet objectForKey:@"event"] == nil || [[tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
        
        if ( [tweet objectForKey:@"text"] == nil ) return @"";
        
        //通常のTweet, 公式RTなど
        text = [NSMutableString stringWithString:[tweet objectForKey:@"text"]];
        
    }else {
    
        if ( [[tweet objectForKey:@"target_object"] objectForKey:@"text"] == nil ) return @"";
        
        //イベント系
        text = [NSMutableString stringWithString:[[tweet objectForKey:@"target_object"] objectForKey:@"text"]];
    }
    
    //ついでに記号も置換
    [text replaceOccurrencesOfString:@"["  withString:@"［" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"]"  withString:@"］" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"&gt;"  withString:@">" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"&lt;"  withString:@"<" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"　"  withString:@" " options:0 range:NSMakeRange(0, [text length] )];
    
    //展開するt.coがない場合は何もせず終了
    if ( [[tweet objectForKey:@"entities"] objectForKey:@"urls"]  == nil &&
         [[tweet objectForKey:@"entities"] objectForKey:@"media"] == nil ) return text;
    
    //t.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"urls"];
    
    //pic.twitter.comへのt.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"media"];
    
    return [NSString stringWithString:text];
}

+ (NSString *)openTcoWithReTweet:(NSDictionary *)tweet {
    
    //公式RTでない場合はtext
    if ( ![[tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
        
//        NSLog(@"not retweet");
        
        return [tweet objectForKey:@"text"];
    }
    
    NSMutableString *text = [NSMutableString stringWithString:[[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"]];
    NSArray *urls = [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:@"urls"];
    NSArray *media = [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:@"media"];
    
    //entitiesがない場合はそのままのtext
    if ( ![EmptyCheck check:urls] && ![EmptyCheck check:media] ) {
     
//        NSLog(@"urls and media is empty");
        
        return [[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"];
    }
    
    //retweeted_status/entities/urls と retweeted_status/entities/media を1つにまとめる
    NSMutableArray *entities = [NSMutableArray array];
    
    for ( id url in urls ) {
        
        [entities addObject:url];
    }
    
    for ( id mediaUrl in media ) {
        
        [entities addObject:mediaUrl];
    }
    
//    NSLog(@"entities: %@", entities);
//    NSLog(@"text: %@", text);
    
    //全て置換を行う
    for ( NSDictionary *entitiy in entities ) {
        
        NSString *replaceUrl = nil;
        NSString *tcoUrl = [entitiy objectForKey:@"url"];
        
        if ( [entitiy objectForKey:@"media_url_https"] == nil ) {
            
            //url
            replaceUrl = [entitiy objectForKey:@"expanded_url"];
            
        }else {
            
            //media
            replaceUrl = [entitiy objectForKey:@"media_url_https"];
        }
        
        //NSLog(@"%@→%@", tcoUrl, replaceUrl);
        
        //置換を行う
        [text replaceOccurrencesOfString:tcoUrl
                              withString:replaceUrl
                                 options:0
                                   range:NSMakeRange( 0, text.length )];
    }
    
    //NSLog(@"ResutlText: %@", text);
    
    //t.coが展開されたReTweet本文が返される
    return [NSString stringWithString:text];
}

//Tweetのtextをt.co展開済みの物に置き換える
+ (NSDictionary *)replaceTco:(NSDictionary *)tweet {
    
    //t.co展開済みの本文を生成
    NSString *text = [TWEntities openTco:tweet];
    
    //textを置き換える
    NSMutableDictionary *replacedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
    [replacedTweet setObject:text forKey:@"text"];
    [replacedTweet setObject:text.linkWrappingAll forKey:@"link_text"];
    
    tweet = [NSDictionary dictionaryWithDictionary:replacedTweet];
    
    return tweet;
}

//t.co置換処理本体
+ (NSMutableString *)replace:(NSDictionary *)tweet text:(NSMutableString *)text entitiesType:(NSString *)entitiesType {
    
    @try {
        
        if ( [[tweet objectForKey:@"entities"] objectForKey:entitiesType] != nil ||
             [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:entitiesType] != nil ) {
            
            //t.coを元のURLに置換する
            
            //t.coの情報を全て読み込む
            NSArray *urls = nil;
            
            //公式RTであるか
            if ( [[tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                
                urls = [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:entitiesType];
                
            }else {
                
                urls = [[tweet objectForKey:@"entities"] objectForKey:entitiesType];
            }
            
            //t.coの情報が無い場合は何もせず終了
            if ( urls.count == 0 ) return text;
            
            for ( NSDictionary *url in urls ) {
                
                //t.coのURL
                NSString *tcoURL = [url objectForKey:@"url"];
                
                //元のURL
                NSString *expandedURL = nil;
                
                if ( [entitiesType isEqualToString:@"urls"] ) {
                    
                    expandedURL = [url objectForKey:@"expanded_url"];
                    
                }else {
                    
                    expandedURL = [url objectForKey:@"media_url_https"];
                }
                
                //置換を行う
                [text replaceOccurrencesOfString:tcoURL
                                      withString:expandedURL
                                         options:0
                                           range:NSMakeRange( 0, text.length )];
            }
        }
        
    }@catch ( NSException *e ) {
        
        //何か起きた時はとりあえず元の本文を返す
        return text;
    }
    
    //t.co展開済みの本文を返す
    return text;
}

//複数のTweetのt.coを全て展開する
+ (id)replaceTcoAll:(id)tweets {
    
    BOOL isMutable = NO;
    
    //型チェック
    if ( ![tweets isKindOfClass:[NSArray class]] &&
         ![tweets isKindOfClass:[NSMutableArray class]]) {
        
        //NSArray でも NSMutableArray でもない場合
        return nil;
    }
    
    //可変長であるかチェック
    if ( [tweets isKindOfClass:[NSMutableArray class]] ) isMutable = YES;
    
    NSMutableArray *replacedTweets = [NSMutableArray array];
    
    //t.coをすべて展開
    for ( id tweet in tweets ) {
        
        NSDictionary *checkedTweet = tweet;
        
        //公式RTであるか
        if ( [[checkedTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
            
            //公式RTの場合はテキストを組み替える
            checkedTweet = [TWParser rtText:checkedTweet];
        }
        
        //t.coを展開して追加
        [replacedTweets addObject:[TWEntities replaceTco:checkedTweet]];
    }
    
    //NSLog(@"replaceTcoAll: %@", replacedTweets);
    
    tweets = replacedTweets;
    
    //固定長で受け取った場合は固定長にして返す
    if ( !isMutable ) tweets = [NSArray arrayWithArray:tweets];
    
    return tweets;
}

@end

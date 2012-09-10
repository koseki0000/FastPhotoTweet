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
        
        //通常のTweet, 公式RTなど
        text = [NSMutableString stringWithString:[tweet objectForKey:@"text"]];
        
    }else {
    
        //イベント系
        text = [NSMutableString stringWithString:[[tweet objectForKey:@"target_object"] objectForKey:@"text"]];
    }
    
    //ついでに記号も置換
    [text replaceOccurrencesOfString:@"&gt;"  withString:@">" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"&lt;"  withString:@"<" options:0 range:NSMakeRange(0, [text length] )];
    [text replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [text length] )];
    
    //展開するt.coがない場合は何もせず終了
    if ( [[tweet objectForKey:@"entities"] objectForKey:@"urls"]  == nil &&
         [[tweet objectForKey:@"entities"] objectForKey:@"media"] == nil ) return text;
    
    //t.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"urls"];
    
    //pic.twitter.comへのt.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"media"];
    
    return [NSString stringWithString:text];
}

//Tweetのtextをt.co展開済みの物に置き換える
+ (NSDictionary *)replaceTco:(NSDictionary *)tweet {
    
    //t.co展開済みの本文を生成
    NSString *text = [TWEntities openTco:tweet];
    
    //textを置き換える
    NSMutableDictionary *replacedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
    [replacedTweet setObject:text forKey:@"text"];
    
    tweet = [NSDictionary dictionaryWithDictionary:replacedTweet];
    
    return tweet;
}

//t.co置換処理本体
+ (NSMutableString *)replace:(NSDictionary *)tweet text:(NSMutableString *)text entitiesType:(NSString *)entitiesType {
    
    @try {
        
        if ( [[tweet objectForKey:@"entities"] objectForKey:entitiesType] != nil ) {
            
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
+ (NSMutableArray *)replaceTcoAll:(NSMutableArray *)tweets {

    NSMutableArray *replacedTweets = [NSMutableArray array];
    
    //t.coをすべて展開
    for ( id tweet in tweets ) {
        
        //公式RTであるか
        if ( [[tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
            
            //公式RTの場合はテキストを組み替える
            tweet = [TWParser rtText:tweet];
        }
        
        //t.coを展開して追加
        [replacedTweets addObject:[TWEntities replaceTco:tweet]];
    }
    
    //NSLog(@"replaceTcoAll: %@", replacedTweets);
    
    return replacedTweets;
}

@end

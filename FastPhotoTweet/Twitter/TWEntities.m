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
    
    if ( [tweet objectForKey:@"event"] == nil ||
        [[tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
        
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
    if ( [[tweet objectForKey:@"entities"] objectForKey:@"urls"] == nil &&
         [[tweet objectForKey:@"entities"] objectForKey:@"media"] == nil ) return text;
    
    //t.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"urls"];
    
    //pic.twitter.comへのt.coの展開を行う
    text = [TWEntities replace:tweet text:text entitiesType:@"media"];
    
    return [NSString stringWithString:text];
}

+ (NSString *)openTcoWithReTweet:(NSDictionary *)tweet {
    
    NSMutableString *text = [[[NSMutableString alloc] initWithString:[[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"]] autorelease];
    NSArray *urls = [[[NSArray alloc] initWithArray:[[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:@"urls"]] autorelease];
    NSArray *media = [[[NSArray alloc] initWithArray:[[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:@"media"]] autorelease];
    
    //entitiesがない場合はそのままのtext
    if ( [urls isNotEmpty] && [media isNotEmpty] ) {
     
        //NSLog(@"urls and media is empty");        
        return [[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"];
    }
    
    //retweeted_status/entities/urls と retweeted_status/entities/media を1つにまとめる
    NSMutableArray *entities = [[[NSMutableArray alloc] init] autorelease];
    
    for ( id url in urls ) {
        
        [entities addObject:url];
    }
    
    for ( id mediaUrl in media ) {
        
        [entities addObject:mediaUrl];
    }
    
    //NSLog(@"entities: %@", entities);
    //NSLog(@"text: %@", text);
    
    //全て置換を行う
    for ( NSDictionary *entitiy in entities ) {
        
        NSString *replaceUrl = nil;
        NSString *tcoUrl = [[[NSString alloc] initWithString:[entitiy objectForKey:@"url"]] autorelease];
        
        if ( [entitiy objectForKey:@"media_url_https"] == nil ) {
            
            //url
            replaceUrl = [[[NSString alloc] initWithString:[entitiy objectForKey:@"expanded_url"]] autorelease];
            
        }else {
            
            //media
            replaceUrl = [[[NSString alloc] initWithString:[entitiy objectForKey:@"media_url_https"]] autorelease];
        }
        
        //NSLog(@"%@→%@", tcoUrl, replaceUrl);
        
        if ( replaceUrl != nil ) {
         
            //置換を行う
            [text replaceOccurrencesOfString:tcoUrl
                                  withString:replaceUrl
                                     options:0
                                       range:NSMakeRange( 0, text.length )];
        }
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
    
    if ( [replacedTweet objectForKey:@"event"] == nil ) {
        
        if ( [[tweet objectForKey:@"retweeted_status"] boolForKey:@"id"] ) {
            
            [replacedTweet setObject:@(CellTextColorGreen) forKey:@"text_color"];
            
            [replacedTweet setObject:[NSString stringWithFormat:@"%@ - %@ [%@]",
                                      [[[replacedTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"],
                                      [TWParser JSTDate:[[replacedTweet objectForKey:@"retweeted_status"] objectForKey:@"created_at"]],
                                      [TWParser client:[[replacedTweet objectForKey:@"retweeted_status"] objectForKey:@"source"]]]
                              forKey:@"info_text"];
            
            [replacedTweet setObject:[NSString stringWithFormat:@"%@_%@",
                                      [[[replacedTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"],
                                      [TWIconBigger normal:[[[[replacedTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]]]
                              forKey:@"search_name"];
            
        }else {
            
            CellTextColor textColor = CellTextColorBlack;
            
            if ( [[[replacedTweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                
                textColor = CellTextColorBlue;
            }
            
            if ( [[replacedTweet objectForKey:@"text"] rangeOfString:[TWAccounts currentAccount].accountDescription].location != NSNotFound ) {
                
                textColor = CellTextColorRed;
            }
            
            NSString *infoLabelText = [NSString stringWithFormat:@"%@ - %@ [%@]",
                                       [[replacedTweet objectForKey:@"user"] objectForKey:@"screen_name"],
                                       [TWParser JSTDate:[replacedTweet objectForKey:@"created_at"]],
                                       [TWParser client:[replacedTweet objectForKey:@"source"]]];
            
            if ( [replacedTweet boolForKey:@"favorited"] ) {
                
                infoLabelText = [NSString stringWithFormat:@"★%@", infoLabelText];
                textColor = CellTextColorGold;
            }
            
            [replacedTweet setObject:@(textColor) forKey:@"text_color"];
            [replacedTweet setObject:infoLabelText forKey:@"info_text"];
            
            [replacedTweet setObject:[NSString stringWithFormat:@"%@_%@",
                                      [[replacedTweet objectForKey:@"user"] objectForKey:@"screen_name"],
                                      [TWIconBigger normal:[[[replacedTweet objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]]]
                              forKey:@"search_name"];
        }
        
    }else if ( [tweet objectForKey:@"event"] != nil &&
              [[tweet stringForKey:@"event"] isEqualToString:@"favorite"] ) {
        
        [replacedTweet setObject:[NSString stringWithFormat:@"%@ - %@ [%@]",
                                  [[[replacedTweet objectForKey:@"target_object"] objectForKey:@"user"] objectForKey:@"screen_name"],
                                  [TWParser JSTDate:[[replacedTweet objectForKey:@"target_object"] objectForKey:@"created_at"]],
                                  [TWParser client:[[replacedTweet objectForKey:@"target_object"] objectForKey:@"source"]]]
                          forKey:@"info_text"];
        
        [replacedTweet setObject:[NSString stringWithFormat:@"%@_%@",
                                  [[[replacedTweet objectForKey:@"target_object"] objectForKey:@"user"] objectForKey:@"screen_name"],
                                  [TWIconBigger normal:[[[[replacedTweet objectForKey:@"target_object"] objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]]]
                          forKey:@"search_name"];
    }
    
    [replacedTweet setObject:@([text heightForContents:[UIFont systemFontOfSize:12.0]
                                               toWidht:264
                                             minHeight:31
                                         lineBreakMode:NSLineBreakByCharWrapping])
                      forKey:@"contents_height"];
    
    return [TWEntities truncateUselessData:replacedTweet];
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
                
                urls = [[[NSArray alloc] initWithArray:[[[tweet objectForKey:@"retweeted_status"] objectForKey:@"entities"] objectForKey:entitiesType]] autorelease];
                
            }else {

                urls = [[[NSArray alloc] initWithArray:[[tweet objectForKey:@"entities"] objectForKey:entitiesType]] autorelease];
            }
            
            //t.coの情報が無い場合は何もせず終了
            if ( [urls isEmpty] ) {

                return text;
            }

            for ( NSDictionary *url in urls ) {
                
                //t.coのURL
                NSString *tcoURL = [[[NSString alloc] initWithString:[url objectForKey:@"url"]] autorelease];

                //元のURL
                NSString *expandedURL = nil;
                
                if ( [entitiesType isEqualToString:@"urls"] ) {

                    expandedURL = [[[NSString alloc] initWithString:[url objectForKey:@"expanded_url"]] autorelease];
                    
                }else {

                    expandedURL = [[[NSString alloc] initWithString:[url objectForKey:@"media_url_https"]] autorelease];
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

+ (NSDictionary *)truncateUselessData:(NSMutableDictionary *)tweet {
    
    [tweet removeObjectForKey:@"coordinates"];
    [tweet removeObjectForKey:@"truncated"];
    [tweet removeObjectForKey:@"contributors"];
    [tweet removeObjectForKey:@"geo"];
    [tweet removeObjectForKey:@"possibly_sensitive"];
    
    NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:[tweet objectForKey:@"user"]];
    
    [user removeObjectForKey:@"profile_sidebar_border_color"];
    [user removeObjectForKey:@"profile_sidebar_fill_color"];
    [user removeObjectForKey:@"profile_background_tile"];
    [user removeObjectForKey:@"is_translator"];
    [user removeObjectForKey:@"profile_link_color"];
    [user removeObjectForKey:@"profile_background_image_url_https"];
    [user removeObjectForKey:@"description"];
    [user removeObjectForKey:@"profile_background_image_url"];
    [user removeObjectForKey:@"profile_background_color"];
    [user removeObjectForKey:@"profile_image_url_https"];
    [user removeObjectForKey:@"url"];
    [user removeObjectForKey:@"geo_enabled"];
    [user removeObjectForKey:@"verified"];
    [user removeObjectForKey:@"notifications"];
    [user removeObjectForKey:@"statuses_count"];
    [user removeObjectForKey:@"friends_count"];
    [user removeObjectForKey:@"show_all_inline_media"];
    [user removeObjectForKey:@"utc_offset"];
    
    [tweet setObject:user forKey:@"user"];
    
    return [NSDictionary dictionaryWithDictionary:tweet];
}

//複数のTweetのt.coを全て展開する
+ (id)replaceTcoAll:(id)tweets {
    
    //型チェック
    if ( ![tweets isKindOfClass:[NSArray class]] &&
         ![tweets isKindOfClass:[NSMutableArray class]]) {
        
        //NSArray でも NSMutableArray でもない場合
        return nil;
    }
    
    NSMutableArray *replacedTweets = [NSMutableArray array];
    
    //t.coをすべて展開
    for ( id tweet in tweets ) {
        
        NSDictionary *checkedTweet = [NSDictionary dictionaryWithDictionary:tweet];
        
        //公式RTであるか
        if ( [[checkedTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
            
            //公式RTの場合はテキストを組み替える
            checkedTweet = [TWParser rtText:checkedTweet];
        }
        
        //t.coを展開して追加
        [replacedTweets addObject:[TWEntities replaceTco:checkedTweet]];
    }
    
    //NSLog(@"replaceTcoAll: %@", replacedTweets);
    
    return [tweets isKindOfClass:[NSArray class]] ? [NSArray arrayWithArray:replacedTweets] : replacedTweets;
}

@end

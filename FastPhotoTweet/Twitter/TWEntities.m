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
    
    if ( [tweet objectForKey:@"event"] == nil ) {
        
        //通常のTweet
        text = [NSMutableString stringWithString:[tweet objectForKey:@"text"]];
        
    }else {
    
        //公式RTなど
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

+ (NSDictionary *)replaceTco:(NSDictionary *)tweet text:(NSString *)text {
    
    return tweet;
}

+ (NSMutableString *)replace:(NSDictionary *)tweet text:(NSMutableString *)text entitiesType:(NSString *)entitiesType {
    
    @try {
        
        if ( [[tweet objectForKey:@"entities"] objectForKey:entitiesType] != nil ) {
            
            //t.coを元のURLに置換する
            
            //t.coの情報を全て読み込む
            NSArray *urls = [[tweet objectForKey:@"entities"] objectForKey:entitiesType];
            
            //t.coの情報が無い場合は何もせず終了
            if ( urls.count == 0 ) return text;
            
            for ( NSDictionary *url in urls ) {
                
                //t.coのURL
                NSString *tcoURL = [url objectForKey:@"url"];
                
                //元のURL
                NSString *expandedURL = [url objectForKey:@"expanded_url"];
                
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

@end

//
//  TWTweetUtility.m
//

#import "TWTweetUtility.h"
#import "TWParser.h"
#import "NSString+Calculator.h"

#define TWEET_TEXT_FONT [UIFont systemFontOfSize:12.0]
#define CELL_MIN_HEIGHT 31.0
#define CELL_WIDHT 264

@implementation TWTweetUtility

+ (NSString *)replaceCharacterReference:(NSString *)text {
    
//    NSLog(@"%s", __func__);
    
    NSMutableString *replacedText = [NSMutableString stringWithString:text];
    [replacedText replaceOccurrencesOfString:@"["
                                  withString:@"［"
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    [replacedText replaceOccurrencesOfString:@"]"
                                  withString:@"］"
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    [replacedText replaceOccurrencesOfString:@"&gt;"
                                  withString:@">"
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    [replacedText replaceOccurrencesOfString:@"&lt;"
                                  withString:@"<"
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    [replacedText replaceOccurrencesOfString:@"&amp;"
                                  withString:@"&"
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    [replacedText replaceOccurrencesOfString:@"　"
                                  withString:@" "
                                     options:0
                                       range:NSMakeRange(0, [replacedText length])];
    
    return [NSString stringWithString:replacedText];
}

+ (NSString *)openTco:(NSString *)text fromEntities:(TWTweetEntities *)entities {
    
//    NSLog(@"%s", __func__);
    
    if ( entities.urls.count == 0 ) return text;
    
    NSMutableString *replacedText = [NSMutableString stringWithString:text];
    
    for ( NSDictionary *url in entities.urls ) {
        
        NSString *tcoURL = url[@"url"];
        NSString *expandedURL = @"";
        
        if ( url[@"media_url_https"] == nil ) {
            
            expandedURL = url[@"expanded_url"];
            
        }else {
            
            expandedURL = url[@"media_url_https"];
        }
        
        [replacedText replaceOccurrencesOfString:tcoURL
                              withString:expandedURL
                                 options:0
                                   range:NSMakeRange(0, replacedText.length)];
    }
    
    return [NSString stringWithString:replacedText];
}

+ (TWTweet *)createTimelineCellInfo:(TWTweet *)tweet {
    
//    NSLog(@"%s", __func__);
    
    //Tweet情報
    NSString *infoText = @"";
    if ( [tweet isReTweet] ) {
        
        infoText = [NSString stringWithFormat:@"%@ - %@ [%@]",
                    tweet.rtUserName,
                    tweet.createdAt,
                    tweet.source];
        
    }else {
        
        infoText = [NSString stringWithFormat:@"%@ - %@ [%@]",
                    tweet.screenName,
                    tweet.createdAt,
                    tweet.source];
    }
    
    [tweet setInfoText:infoText];
    
    //セルの高さ
    CGFloat height = [tweet.text heightForContents:[UIFont systemFontOfSize:12.0]
                                           toWidht:CELL_WIDHT
                                         minHeight:CELL_MIN_HEIGHT
                                     lineBreakMode:NSLineBreakByCharWrapping];
    [tweet setCellHeight:height];
    
    //Tweetの色を決定
    if ( [tweet isFavorited] ) {
        
        [tweet setTextColor:CellTextColorGold];
        
    }else {
        
        if ( [tweet isReTweet] ) {
            
            [tweet setTextColor:CellTextColorGreen];
            
        }else {
            
            if ( [tweet isReply] ) {
                
                [tweet setTextColor:CellTextColorRed];
                
            }else {
                
                if ( [tweet isMyTweet] ) {
                    
                    [tweet setTextColor:CellTextColorBlue];
                    
                }else {
                    
                    [tweet setTextColor:CellTextColorBlack];
                }
            }
        }
    }
    
    return tweet;
}

@end

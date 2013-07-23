//
//  TWTweet.m
//

#import "TWTweet.h"
#import "TWTweetUtility.h"
#import "TWAccounts.h"
#import "TWParser.h"
#import "TWIconResizer.h"
#import "NSString+RegularExpression.h"
#import "NSString+Calculator.h"
#import "NSAttributedString+Attributes.h"

@implementation TWTweet

#define TWEET_TEXT_FONT_SIZE 12.0f
#define TWEET_TEXT_FONT [UIFont systemFontOfSize:TWEET_TEXT_FONT_SIZE]
#define CELL_MIN_HEIGHT 31.0f
#define CELL_RT_MIN_HEIGHT 37.0f
#define CELL_WIDHT 264.0f

#define SEARCH_PATH [NSString stringWithFormat:@"%@-%@", tweet.screenName, [tweet.iconURL lastPathComponent]]
#define RT_SEARCH_PATH [NSString stringWithFormat:@"%@-%@", tweet.rtUserName, [tweet.rtIconURL lastPathComponent]]
#define SCREEN_NAME [tweet isReTweet] ? tweetDictionary[@"retweeted_status"][@"user"][@"screen_name"] : tweetDictionary[@"user"][@"screen_name"]
#define ICON_URL [tweet isReTweet] ? tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"] : tweetDictionary[@"user"][@"profile_image_url"]

- (void)debugLog {
    
    NSLog(@"entities.urls: %@", self.entities.urls);
    NSLog(@"entities.userMentions: %@", self.entities.userMentions);
    
    NSLog(@"text: %@", self.text);
    NSLog(@"screenName: %@", self.screenName);
    NSLog(@"iconURL: %@", self.iconURL);
    NSLog(@"iconSearchPath: %@", self.iconSearchPath);
    NSLog(@"infoText: %@", self.infoText);
    NSLog(@"inReplyToID: %@", self.inReplyToID);
    NSLog(@"tweetID: %@", self.tweetID);
    NSLog(@"source: %@", self.source);
    NSLog(@"createdAt: %@", self.createdAt);
    
    NSLog(@"rtUserName: %@", self.rtUserName);
    NSLog(@"rtIconURL: %@", self.rtIconURL);
    NSLog(@"rtIconSearchPath: %@", self.rtIconSearchPath);
    NSLog(@"rtID: %@", self.rtID);
    
    NSLog(@"textColor: %d", self.textColor);
    NSLog(@"cellHeight: %.0f", self.cellHeight);
    NSLog(@"isMyTweet: %@", self.isMyTweet ? @"YES" : @"NO");
    NSLog(@"isReply: %@", self.isReply ? @"YES" : @"NO");
    NSLog(@"isReTweet: %@", self.isReTweet ? @"YES" : @"NO");
    NSLog(@"isFavorited: %@", self.isFavorited ? @"YES" : @"NO");
    NSLog(@"isEvent: %@", self.isEvent ? @"YES" : @"NO");
    NSLog(@"isDelete: %@", self.isDelete ? @"YES" : @"NO");
    NSLog(@"eventType: %@", self.eventType);
    NSLog(@"error: %@", self.error);
    NSLog(@"-------------------------");
}

+ (TWTweet *)tweetWithDictionary:(NSDictionary *)tweetDictionary {
    
    //    NSLog(@"%s", __func__);
    
    TWTweet *tweet = [[[TWTweet alloc] init] autorelease];
    
    IconSize iconSize;
    NSString *iconQualitySetting = [USER_DEFAULTS objectForKey:@"IconQuality"];
    
    if ( [iconQualitySetting isEqualToString:@"Mini"] ) {
        iconSize = IconSizeMini;
    } else if ( [iconQualitySetting isEqualToString:@"Normal"] ) {
        iconSize = IconSizeNormal;
    } else if ( [iconQualitySetting isEqualToString:@"Bigger"] ) {
        iconSize = IconSizeBigger;
    } else if ( [iconQualitySetting isEqualToString:@"Original"] ) {
        iconSize = IconSizeOriginal;
    } else if ( [iconQualitySetting isEqualToString:@"Original96"] ) {
        iconSize = IconSizeOriginal96;
    } else {
        iconSize = IconSizeBigger;
    }
    
    if ( tweetDictionary[@"event"] ) {
        
        [tweet setIsEvent:YES];
        [tweet setEventType:tweetDictionary[@"event"]];
        
        if ( [tweet.eventType isEqualToString:@"favorite"] &&
            ![tweetDictionary[@"source"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] &&
            [tweetDictionary[@"target"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
            
            //ふぁぼられ
            [tweet setEventType:@"ReceiveFavorite"];
            [tweet setFavoriteEventeType:FavoriteEventTypeReceive];
            
            [tweet setScreenName:tweetDictionary[@"target"][@"screen_name"]];
            
            [tweet setIconURL:[TWIconResizer iconURL:tweetDictionary[@"target"][@"user"][@"profile_image_url"]
                                            iconSize:iconSize]];
            [tweet setCreatedAt:[TWParser JSTDate:tweetDictionary[@"target_object"][@"created_at"]]];
            [tweet setSource:[TWParser client:tweetDictionary[@"target_object"][@"source"]]];
            [tweet setText:tweetDictionary[@"target_object"][@"text"]];
            [tweet setIsFavorited:YES];
            [tweet setFavUser:tweetDictionary[@"source"][@"screen_name"]];
            [tweet setTextColor:@(CellTextColorGold)];
            
            //アイコン検索名
            [tweet setIconSearchPath:SEARCH_PATH];
            
            [tweet setEntities:[TWTweetEntities entitiesWithDictionary:tweetDictionary]];
            
            //t.coを展開
            [tweet setText:[TWTweetUtility openTco:tweet.text
                                      fromEntities:tweet.entities]];
            
            //参照文字列を置換
            [tweet setText:[TWTweetUtility replaceCharacterReference:tweet.text]];
            
            [tweet createTimelineCellInfo];
            
        } else if ( [tweet.eventType isEqualToString:@"favorite"] &&
                  [tweetDictionary[@"source"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] &&
                  [tweetDictionary[@"target"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
            
            //ふぁぼった
            [tweet setFavoriteEventeType:FavoriteEventTypeAdd];
            
        } else if ( [tweet.eventType isEqualToString:@"unfavorite"] ) {
            
            //ふぁぼ外した
            [tweet setFavoriteEventeType:FavoriteEventTypeRemove];
        }
        
        [tweet setTweetID:tweetDictionary[@"target_object"][@"id_str"]];
        
    } else if ( tweetDictionary[@"delete"] ) {
        
        [tweet setIsDelete:YES];
        [tweet setTweetID:tweetDictionary[@"delete"][@"status"][@"id_str"]];
        [tweet setScreenName:tweetDictionary[@"source"][@"screen_name"]];
        
    } else {
        
        //RT判定
        [tweet setIsReTweet:[tweetDictionary[@"retweeted_status"][@"id"] boolValue]];
        
        [tweet setScreenName:SCREEN_NAME];
        
        //ふぁぼり判定
        [tweet setIsFavorited:[tweetDictionary[@"favorited"] boolValue]];
        //自分のTweet判定
        [tweet setIsMyTweet:[tweet.screenName isEqualToString:[TWAccounts currentAccountName]]];
        
        [tweet setIconURL:[TWIconResizer iconURL:ICON_URL
                                        iconSize:iconSize]];
        [tweet setTweetID:tweetDictionary[@"id_str"]];
        [tweet setInReplyToID:tweetDictionary[@"in_reply_to_status_id_str"]];
        
        //アイコン検索名
        [tweet setIconSearchPath:SEARCH_PATH];
        
        if ( [tweet isReTweet] ) {
            
            //RTした人
            [tweet setRtUserName:tweetDictionary[@"retweeted_status"][@"user"][@"screen_name"]];
            
            [tweet setSource:[TWParser client:tweetDictionary[@"retweeted_status"][@"source"]]];
            [tweet setCreatedAt:[TWParser JSTDate:tweetDictionary[@"retweeted_status"][@"created_at"]]];
            [tweet setRtUserName:tweetDictionary[@"user"][@"screen_name"]];
            [tweet setRtIconURL:[TWIconResizer iconURL:tweetDictionary[@"user"][@"profile_image_url"]
                                              iconSize:iconSize]];
            [tweet setRtIconSearchPath:RT_SEARCH_PATH];
            [tweet setTweetID:tweetDictionary[@"retweeted_status"][@"id_str"]];
            
            //RTのテキスト
            [tweet setText:[NSString stringWithFormat:@"%@\nRetweeted by @%@", tweetDictionary[@"retweeted_status"][@"text"], tweet.rtUserName]];
            [tweet setRtID:tweetDictionary[@"id_str"]];
            [tweet setOriginalText:tweetDictionary[@"retweeted_status"][@"text"]];
            [tweet setEntities:[TWTweetEntities rtEntitiesWithDictionary:tweetDictionary]];
            
        } else {
            
            [tweet setText:tweetDictionary[@"text"]];
            
            [tweet setSource:[TWParser client:tweetDictionary[@"source"]]];
            [tweet setCreatedAt:[TWParser JSTDate:tweetDictionary[@"created_at"]]];
            [tweet setEntities:[TWTweetEntities entitiesWithDictionary:tweetDictionary]];
        }
        
        //Reply判定
        [tweet setIsReply:([tweet.text rangeOfString:[TWAccounts currentAccountName]].location != NSNotFound)];
        
        //t.coを展開
        [tweet setText:[TWTweetUtility openTco:tweet.text
                                  fromEntities:tweet.entities]];
        
        //参照文字列を置換
        [tweet setText:[TWTweetUtility replaceCharacterReference:tweet.text]];
        
        [tweet createTimelineCellInfo];
    }
    
    return tweet;
}

+ (UIColor *)getTextColor:(CellTextColor)color {
    
    if ( color == CellTextColorBlack ) return BLACK_COLOR;
    if ( color == CellTextColorRed )   return RED_COLOR;
    if ( color == CellTextColorBlue )  return BLUE_COLOR;
    if ( color == CellTextColorGreen ) return GREEN_COLOR;
    if ( color == CellTextColorGold )  return GOLD_COLOR;
    
    return BLACK_COLOR;
}

- (void)createTimelineCellInfo {
    
    //    NSLog(@"%s", __func__);
    
    //Tweet情報
    NSString *infoText = [NSString stringWithFormat:@"%@ - %@ [%@]",
                          self.screenName,
                          self.createdAt,
                          self.source];
    [self setInfoText:infoText];
    
    //Tweetの色を決定
    if ( [self isFavorited] ) {
        
        [self setTextColor:CellTextColorGold];
        
    } else {
        
        if ( [self isReTweet] ) {
            
            [self setTextColor:CellTextColorGreen];
            
        } else {
            
            if ( [self isReply] ) {
                
                [self setTextColor:CellTextColorRed];
                
            } else {
                
                if ( [self isMyTweet] ) {
                    
                    [self setTextColor:CellTextColorBlue];
                    
                } else {
                    
                    [self setTextColor:CellTextColorBlack];
                }
            }
        }
    }
    
    //セルの高さ
    NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:self.text];
    [mainText setFont:[UIFont systemFontOfSize:TWEET_TEXT_FONT_SIZE]];
                     range:NSMakeRange(0,
                                       [self.text length]);
    [mainText setTextColor:[TWTweet getTextColor:self.textColor]];
    [mainText setTextAlignment:kCTLeftTextAlignment
                 lineBreakMode:kCTLineBreakByCharWrapping
                 maxLineHeight:14.0f
                 minLineHeight:14.0f
                maxLineSpacing:1.0f
                minLineSpacing:1.0f
                         range:NSMakeRange(0.0f,
                                           mainText.length)];
    [self setAttributedString:mainText];
    
    CGSize mainTextLabelSize = [mainText sizeConstrainedToSize:CGSizeMake(CELL_WIDHT,
                                                                          20000.0f)];
    [self setCellHeight:mainTextLabelSize.height];
    
    CGSize menuTextLabelSize = [mainText sizeConstrainedToSize:CGSizeMake(210.0f,
                                                                          20000.0f)];
    
    [self setMenuCellHeight:menuTextLabelSize.height];
}

@end

//
//  TWTweet.h
//

#import <Foundation/Foundation.h>

@class TWTweetEntities;

typedef enum {
    CellTextColorBlack,
    CellTextColorRed,
    CellTextColorBlue,
    CellTextColorGreen,
    CellTextColorGold
}CellTextColor;

@interface TWTweet : NSObject

//Tweet
@property (nonatomic, retain) TWTweetEntities *entities;
@property (nonatomic, copy) NSString *text;
//発言したユーザー
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *iconURL;
@property (nonatomic, copy) NSString *iconSearchPath;
@property (nonatomic, copy) NSString *infoText;
@property (nonatomic, copy) NSString *inReplyToID;
@property (nonatomic, copy) NSString *tweetID;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *createdAt;

//RTしたユーザー
@property (nonatomic, copy) NSString *rtUserName;
@property (nonatomic, copy) NSString *rtIconURL;
@property (nonatomic, copy) NSString *rtIconSearchPath;
@property (nonatomic, copy) NSString *rtID;

//Info
@property (nonatomic) CellTextColor textColor;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) BOOL isMyTweet;
@property (nonatomic) BOOL isReply;
@property (nonatomic) BOOL isReTweet;
@property (nonatomic) BOOL isFavorited;
@property (nonatomic) BOOL isEvent;

- (void)debugLog;

+ (TWTweet *)tweetWithDictionary:(NSDictionary *)tweetDictionary;

@end

//
//  TWTweet.h
//

#import <Foundation/Foundation.h>

#define BLACK_COLOR [UIColor blackColor]
#define GREEN_COLOR [UIColor colorWithRed:0.0f green:0.4f blue:0.0f alpha:1.0f]
#define BLUE_COLOR  [UIColor blueColor]
#define RED_COLOR   [UIColor redColor]
#define GOLD_COLOR  [UIColor colorWithRed:0.5f green:0.4f blue:0.0f alpha:1.0f]

@class TWTweetEntities;

typedef enum {
    CellTextColorBlack,
    CellTextColorRed,
    CellTextColorBlue,
    CellTextColorGreen,
    CellTextColorGold
}CellTextColor;

typedef enum {
    FavoriteEventTypeAdd,
    FavoriteEventTypeRemove,
    FavoriteEventTypeReceive
}FavoriteEventType;

@interface TWTweet : NSObject

//Tweet
@property (nonatomic, retain) TWTweetEntities *entities;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *originalText;

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

//ふぁぼったユーザー
@property (nonatomic, copy) NSString *favUser;

//Info
@property (nonatomic) CellTextColor textColor;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) BOOL isMyTweet;
@property (nonatomic) BOOL isReply;
@property (nonatomic) BOOL isReTweet;
@property (nonatomic) BOOL isFavorited;
@property (nonatomic) FavoriteEventType favoriteEventeType;
@property (nonatomic) BOOL isEvent;
@property (nonatomic) BOOL isDelete;
@property (nonatomic, copy) NSString *eventType;
@property (nonatomic, copy) NSString *error;

- (void)debugLog;

//表示用の情報関連
+ (TWTweet *)tweetWithDictionary:(NSDictionary *)tweetDictionary;
+ (UIColor *)getTextColor:(CellTextColor)color;
- (void)createTimelineCellInfo;

@end

//
//  FPTRequest.h
//  FastPhotoTweet
//

#import <Twitter/Twitter.h>

#define TIMELINE_LIST_MODE @"timelime_list_mode"
#define NEED_SELECT_ACCOUNT @"need_select_account"

#define LIST_ID @"list_id"

#define RESPONSE_DATA @"ResponseData"
#define REQUEST_USER_NAME @"RequestUserName"
#define REQUEST_LIST_ID @"RequestListID"

#define HOME_TIMELINE_DONE_NOTIFICATION @"HomeTimelineDoneNotification"
#define USER_TIMELINE_DONE_NOTIFICATION @"UserTimelineDoneNotification"
#define MENTIONS_DONE_NOTIFICATION @"MentionsDoneNotification"
#define FAVORITES_DONE_NOTIFICATION @"FavoritesDoneNotification"
#define SEARCH_DONE_NOTIFICATION @"SearchDoneNotification"
#define TWEET_DONE_NOTIFICATION @"TweetDoneNotification"
#define PROFILE_DONE_NOTIFICATION @"ProfileDoneNotification"
#define LISTS_LIST_DONE_NOTIFICATION @"ListsListDoneNotification"
#define LIST_DONE_NOTIFICATION @"ListDoneNotification"

#define POST_DONE_NOTIFICATION @"PostDoneNotification"
#define POST_WITH_MEDIA_DONE_NOTIFICATION @"PostWithMediaDoneNotification"
#define FAVORITE_DONE_NOTIFICATION @"FavoriteDoneNotification"
#define UN_FAVORITE_DONE_NOTIFICATION @"UnFavoriteDoneNotification"
#define RETWEET_DONE_NOTIFICATION @"ReTweetDoneNotification"
#define DESTORY_DONE_NOTIFICATION @"DestroyDoneNotification"

#define GET_API_ERROR_NOTIFICATION @"GETAPIError"
#define POST_API_ERROR_NOTIFICATION @"POSTAPIError"

typedef enum {
    FPTGetRequestTypeHomeTimeline,
    FPTGetRequestTypeUserTimeline,
    FPTGetRequestTypeMentions,
    FPTGetRequestTypeFavorites,
    FPTGetRequestTypeSearch,
    FPTGetRequestTypeTweet,
    FPTGetRequestTypeProfile,
    FPTGetRequestTypeListsList,
    FPTGetRequestTypeList
}FPTGetRequestType;

typedef enum {
    FPTPostRequestTypeText,
    FPTPostRequestTypeTextWithMedia,
    FPTPostRequestTypeFavorite,
    FPTPostRequestTypeUnFavorite,
    FPTPostRequestTypeReTweet,
    FPTPostRequestTypeDestroy
}FPTPostRequestType;

@interface FPTRequest : TWRequest

//GET
+ (void)requestWithGetType:(FPTGetRequestType)getRequestType
                parameters:(NSDictionary *)parameters;

//POST
+ (void)requestWithPostType:(FPTPostRequestType)postRequestType
                 parameters:(NSDictionary *)parameters;

//SEARCH
- (NSArray *)fixTwitterSearchResponse:(NSArray *)twitterSearchResponse;

@end

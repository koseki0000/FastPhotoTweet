//
//  FPTRequest.m
//  FastPhotoTweet
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "FPTRequest.h"

#import "TWTweet.h"
#import "TWAccounts.h"
#import "TWTweets.h"
#import "TWNgTweet.h"

#import "InternetConnection.h"
#import "ActivityIndicator.h"
#import "ShowAlert.h"
#import "EncodeImage.h"
#import "ResizeImage.h"
#import "NSObject+EmptyCheck.h"
#import "NSNotificationCenter+EasyPost.h"

#define API_VERSION @"1.1"

#define HOMETIMELINE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/home_timeline.json", API_VERSION]
#define USERTIMELINE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/user_timeline.json", API_VERSION]
#define MENTIONS_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/mentions_timeline.json", API_VERSION]
#define FAVORITES_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/list.json", API_VERSION]
#define SEARCH_URL @"http://search.twitter.com/search.json"
#define TWEET_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/show.json", API_VERSION]
#define PROFILE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/users/show.json", API_VERSION]

#define LISTS_LIST_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/lists/list.json", API_VERSION]
#define LIST_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/lists/statuses.json", API_VERSION]

#define POST_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/update.json", API_VERSION]
#define POST_WITH_MEDIA_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/update_with_media.json", API_VERSION]
#define FAVORITE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/create.json", API_VERSION]
#define UN_FAVORITE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/destroy.json", API_VERSION]
#define RETWEET_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/retweet/%@.json", API_VERSION , parameters[@"id"]]
#define DESTROY_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/destroy/%@.json", API_VERSION, parameters[@"id"]]

@interface FPTRequest()

+ (void)postAPIErrorNotificationName:(NSString *)notificationName;
+ (void)postAPIErrorNotificationName:(NSString *)notificationName userInfo:(id)userInfo;
- (NSArray *)fixTwitterSearchResponse:(NSArray *)twitterSearchResponse;

@end

@implementation FPTRequest

#pragma mark - GET
+ (oneway void)requestWithGetType:(FPTGetRequestType)getRequestType
                parameters:(NSDictionary *)parameters {
    
    NSLog(@"%s[%d]: %@", __func__, getRequestType, parameters);
    
    BOOL timelineListMode = NO;
    
    if ( parameters[TIMELINE_LIST_MODE] != nil ) {
        
        timelineListMode = YES;
    }
    
    if ( timelineListMode ) {
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [tempDic removeObjectForKey:TIMELINE_LIST_MODE];
        [tempDic removeObjectForKey:NEED_SELECT_ACCOUNT];
        parameters = [NSDictionary dictionaryWithDictionary:tempDic];
    }
    
    dispatch_queue_t getRequestQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(getRequestQueue, ^{
       
        if ( [InternetConnection disable] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"ネットワーク未接続"];
                [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
            });
            
            return;
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ActivityIndicator on];
            });
        }
        
        NSString *requestURL = nil;
        __block NSString *notificationName = nil;
        
        switch ( getRequestType ) {
                
            case FPTGetRequestTypeHomeTimeline:
                requestURL = HOMETIMELINE_URL;
                notificationName = HOME_TIMELINE_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeUserTimeline:
                requestURL = USERTIMELINE_URL;
                notificationName = USER_TIMELINE_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeMentions:
                requestURL = MENTIONS_URL;
                notificationName = MENTIONS_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeFavorites:
                requestURL = FAVORITES_URL;
                notificationName = FAVORITES_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeSearch:
                requestURL = SEARCH_URL;
                notificationName = SEARCH_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeTweet:
                requestURL = TWEET_URL;
                notificationName = TWEET_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeProfile:
                requestURL = PROFILE_URL;
                notificationName = PROFILE_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeListsList:
                requestURL = LISTS_LIST_URL;
                notificationName = LISTS_LIST_DONE_NOTIFICATION;
                break;
                
            case FPTGetRequestTypeList:
                requestURL = LIST_URL;
                notificationName = LIST_DONE_NOTIFICATION;
                break;
                
            default:
                break;
        }
        
        if ( [requestURL isEmpty] ||
             [notificationName isEmpty] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"RequestError"];
                [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
            });
            return;
        }
        
        NSLog(@"requestURL: %@", requestURL);
        
        FPTRequest *request = [[FPTRequest alloc] initWithURL:[NSURL URLWithString:requestURL]
                                                   parameters:parameters
                                                requestMethod:TWRequestMethodGET];
        
        [request setAccount:[TWAccounts currentAccount]];
        
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( error ) {
                    
                    [ShowAlert error:[error localizedDescription]];
                    [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
                    return;
                }
                
                NSString *responseString = [[NSString alloc] initWithData:responseData
                                                                 encoding:NSUTF8StringEncoding];
                
                if ( [responseData isEmpty] ||
                     [responseString isEqualToString:@"[]"] ) {
                    
                    [ShowAlert error:@"レスポンスがありません。"];
                    [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
                    return;
                }
                
                NSError *jsonError = nil;
                id tweetData = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:NSJSONReadingMutableLeaves
                                                                 error:&jsonError];
                if ( jsonError ) {
                    
                    [ShowAlert error:@"レスポンス展開エラー"];
                    [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
                    return;
                }
                
                if ( [tweetData isKindOfClass:[NSArray class]] ||
                      getRequestType == FPTGetRequestTypeSearch ) {
                    
                    NSArray *tweetDataArray = nil;
                    
                    if ( getRequestType == FPTGetRequestTypeSearch ) {
                        
                        tweetDataArray = [request fixTwitterSearchResponse:[tweetData objectForKey:@"results"]];
                        
                    } else {
                        
                        tweetDataArray = (NSArray *)tweetData;
                    }
                
                    if ( timelineListMode ) {
                        
                        notificationName = HOME_TIMELINE_DONE_NOTIFICATION;
                    }
                    
                    if ( getRequestType == FPTGetRequestTypeListsList ) {
                    
                        NSDictionary *userInfo = @{RESPONSE_DATA : tweetDataArray,
                                                   REQUEST_USER_NAME : request.account.username};
                        
                        [NSNotificationCenter postNotificationCenterForName:notificationName
                                                               withUserInfo:userInfo];
                        
                    } else {
                        
                        NSMutableArray *convertedTweets = [NSMutableArray array];
                        for ( id tweet in tweetDataArray ) {
                            
                            TWTweet *convertedTweet = [TWTweet tweetWithDictionary:tweet];
                            [convertedTweets addObject:convertedTweet];
                        }
                        
                        convertedTweets = [TWNgTweet ngAll:convertedTweets];
                        
                        NSDictionary *userInfo = @{RESPONSE_DATA : convertedTweets,
                                                   REQUEST_USER_NAME : request.account.username};
                        
                        [NSNotificationCenter postNotificationCenterForName:notificationName
                                                               withUserInfo:userInfo];
                    }
                    
                }else if ( [tweetData isKindOfClass:[NSDictionary class]] ) {
                    
                    NSDictionary *tweetDataDic = (NSDictionary *)tweetData;
                    if ( tweetDataDic[@"errors"] == nil ) {
                        
                        if ( getRequestType == FPTGetRequestTypeProfile ) {
                            
                            NSDictionary *userInfo = @{RESPONSE_DATA : tweetDataDic,
                                                       REQUEST_USER_NAME : request.account.username};
                            [NSNotificationCenter postNotificationCenterForName:notificationName
                                                                   withUserInfo:userInfo];
                            
                        } else {
                            
                            TWTweet *convertedTweet = [TWTweet tweetWithDictionary:tweetDataDic];
                            NSDictionary *userInfo = @{RESPONSE_DATA : convertedTweet,
                                                       REQUEST_USER_NAME : request.account.username};
                            [NSNotificationCenter postNotificationCenterForName:notificationName
                                                                   withUserInfo:userInfo];
                        }
                        
                    } else {
                        
                        [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION
                                                     userInfo:tweetData];
                    }
                    
                } else {
                    
                    [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
                    return;
                }
                
                [ActivityIndicator off];
            });
        }];
    });
}

#pragma mark - POST
+ (oneway void)requestWithPostType:(FPTPostRequestType)postRequestType
                 parameters:(NSDictionary *)parameters {
    
    BOOL needSelectAccount = NO;
    NSInteger index = 0;
    if ( parameters[NEED_SELECT_ACCOUNT] != nil ) {
        
        needSelectAccount = YES;
        index = [parameters[NEED_SELECT_ACCOUNT] integerValue];
    }
    
    if ( needSelectAccount ) {
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [tempDic removeObjectForKey:NEED_SELECT_ACCOUNT];
        parameters = [NSDictionary dictionaryWithDictionary:tempDic];
    }
    
    __block FPTPostRequestType postRequestTypeTemp = postRequestType;
    
    dispatch_queue_t postRequestQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(postRequestQueue, ^{
        
        if ( [parameters isEmpty] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"パラメータがありません"];
                [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
            });
            return;
        }
        
        if ( [InternetConnection disable] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"ネットワーク未接続"];
                [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
            });
            
            return;
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ActivityIndicator on];
            });
        }
        
        NSString *requestURL = nil;
        NSString *notificationName = nil;
        UIImage *image = nil;
        BOOL withMedia = NO;
        
        switch ( postRequestTypeTemp ) {
                
            case FPTPostRequestTypeText:
                requestURL = POST_URL;
                notificationName = POST_DONE_NOTIFICATION;
                break;
                
            case FPTPostRequestTypeTextWithMedia:
                requestURL = POST_WITH_MEDIA_URL;
                notificationName = POST_WITH_MEDIA_DONE_NOTIFICATION;
                image = parameters[@"image"];
                
                if ( image == nil ) {
                    
                    postRequestTypeTemp = FPTPostRequestTypeText;
                    
                } else {
                    
                    withMedia = YES;
                    
                    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"ResizeImage"] ) {
                        
                        image = [ResizeImage aspectResize:image];
                    }
                }
                
                break;
                
            case FPTPostRequestTypeFavorite:
                requestURL = FAVORITE_URL;
                notificationName = FAVORITE_DONE_NOTIFICATION;
                break;
                
            case FPTPostRequestTypeUnFavorite:
                requestURL = UN_FAVORITE_URL;
                notificationName = UN_FAVORITE_DONE_NOTIFICATION;
                break;
                
            case FPTPostRequestTypeReTweet:
                requestURL = RETWEET_URL;
                notificationName = RETWEET_DONE_NOTIFICATION;
                break;
                
            case FPTPostRequestTypeDestroy:
                requestURL = DESTROY_URL;
                notificationName = DESTORY_DONE_NOTIFICATION;
                break;
                
            default:
                break;
        }
        
        if ( [requestURL isEmpty] ||
             [notificationName isEmpty] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"RequestError"];
                [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
            });
            return;
        }
        
        NSString *status = nil;
        NSString *inReplyToID = nil;
        
        if ( postRequestType == (FPTPostRequestTypeText | FPTPostRequestTypeTextWithMedia) ) {
        
            status = parameters[@"status"];
            inReplyToID = parameters[@"in_reply_to_status_id"];
            
            NSDictionary *saveTweet = @{@"UserName" : [TWAccounts currentAccountName],
                                        @"Parameters" : parameters};
            
            [[TWTweets sendedTweets] addObject:saveTweet];
        }
        
        FPTRequest *request = [[FPTRequest alloc] initWithURL:[NSURL URLWithString:requestURL]
                                                   parameters:withMedia ? nil : parameters
                                                requestMethod:TWRequestMethodPOST];
        
        if ( needSelectAccount ) {
            
            [request setAccount:[TWAccounts selectAccount:index]];
            
        } else {
            
            [request setAccount:[TWAccounts currentAccount]];
        }
        
        if ( withMedia ) {
            
            [request addMultiPartData:[status dataUsingEncoding:NSUTF8StringEncoding]
                             withName:@"status"
                                 type:@"multipart/form-data"];
            
            [request addMultiPartData:[EncodeImage image:image]
                             withName:@"media[]"
                                 type:@"multipart/form-data"];
            
            if ( [inReplyToID isNotEmpty] ) {
                
                [request addMultiPartData:[inReplyToID dataUsingEncoding:NSUTF8StringEncoding]
                                 withName:@"in_reply_to_status_id"
                                     type:@"multipart/form-data"];
            }
        }
        
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( error ) {
                    
                    [ShowAlert error:[error localizedDescription]];
                    [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
                    return;
                }
                
                NSString *responseString = [[NSString alloc] initWithData:responseData
                                                                 encoding:NSUTF8StringEncoding];
                
                if ( [responseData isEmpty] ||
                     [responseString isEqualToString:@"[]"] ) {
                    
                    [ShowAlert error:@"レスポンスがありません。"];
                    [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
                    return;
                }
                
                NSError *jsonError = nil;
                id resultData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&jsonError];
                if ( jsonError ) {
                    
                    [ShowAlert error:@"レスポンス展開エラー"];
                    [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
                    return;
                }
                
                if ( [resultData isKindOfClass:[NSDictionary class]] ) {
                    
                    NSDictionary *resultDic = (NSDictionary *)resultData;
                    
                    if ( [resultDic objectForKey:@"error"] != nil ||
                         [resultDic objectForKey:@"text"] == nil ) {
                        
                        if ( [resultDic objectForKey:@"error"] != nil ) {
                            
                            [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION
                                                            userInfo:resultData];
                        }
                        
                    }else if ( [resultDic objectForKey:@"error"] == nil &&
                               [resultDic objectForKey:@"text"] != nil ) {
                        
                        TWTweet *tweet = [TWTweet tweetWithDictionary:resultDic];
                        
                        NSDictionary *userInfo = @{@"SendedText" : tweet.text,
                                                   REQUEST_USER_NAME : request.account.username};
                        
                        [NSNotificationCenter postNotificationCenterForName:notificationName
                                                               withUserInfo:userInfo];
                        
                        
                    } else {
                        
                        [ShowAlert error:@"不明なエラー"];
                        [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
                    }
                    
                } else {
                    
                    [ShowAlert error:@"不明なレスポンス"];
                    [FPTRequest postAPIErrorNotificationName:POST_API_ERROR_NOTIFICATION];
                }
                
                [ActivityIndicator off];
            });
        }];
    });
}

#pragma mark - SEARCH
- (NSArray *)fixTwitterSearchResponse:(NSArray *)twitterSearchResponse {
    
    NSLog(@"%s", __func__);
    
    NSMutableArray *fixedResponse = [NSMutableArray array];
    
    for ( id tweet in twitterSearchResponse ) {
        
        NSMutableDictionary *fixedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
        
        NSMutableDictionary *user = [NSMutableDictionary dictionary];
        [user setObject:[fixedTweet objectForKey:@"from_user"]
                 forKey:@"screen_name"];
        [user setObject:[fixedTweet objectForKey:@"profile_image_url"]
                 forKey:@"profile_image_url"];
        [user setObject:[fixedTweet objectForKey:@"from_user_id_str"]
                 forKey:@"id_str"];
        
        NSMutableString *source = [fixedTweet objectForKey:@"source"];
        [source replaceOccurrencesOfString:@"&gt;"
                                withString:@">"
                                   options:0
                                     range:NSMakeRange(0,
                                                       [source length])];
        [source replaceOccurrencesOfString:@"&lt;"
                                withString:@"<"
                                   options:0
                                     range:NSMakeRange(0,
                                                       [source length])];
        [source replaceOccurrencesOfString:@"&amp;"
                                withString:@"&"
                                   options:0
                                     range:NSMakeRange(0,
                                                       [source length])];
        [source replaceOccurrencesOfString:@"&quot;"
                                withString:@"\""
                                   options:0
                                     range:NSMakeRange(0,
                                                       [source length])];
        
        [fixedTweet setObject:user forKey:@"user"];
        [fixedTweet setObject:source forKey:@"source"];
        [fixedResponse addObject:fixedTweet];
    }
    
    return [NSArray arrayWithArray:fixedResponse];
}

+ (void)postAPIErrorNotificationName:(NSString *)notificationName {
    
    [FPTRequest postAPIErrorNotificationName:notificationName
                                    userInfo:nil];
}

+ (void)postAPIErrorNotificationName:(NSString *)notificationName userInfo:(id)userInfo {
    
    [NSNotificationCenter postNotificationCenterForName:notificationName
                                           withUserInfo:userInfo ? @{@"ErrorResponseData" : userInfo} : nil];
}

@end

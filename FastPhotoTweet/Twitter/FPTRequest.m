//
//  FPTRequest.m
//  FastPhotoTweet
//

#import <Accounts/Accounts.h>

#import "FPTRequest.h"

#import "TWTweet.h"
#import "TWAccounts.h"
#import "TWTweets.h"
#import "TWTweetUtility.h"
#import "TWNgTweet.h"

#import "InternetConnection.h"
#import "ActivityIndicator.h"
#import "ShowAlert.h"
#import "NSObject+EmptyCheck.h"
#import "NSNotificationCenter+EasyPost.h"

#define API_VERSION @"1.1"

#define HOMETIMELINE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/home_timeline.json", API_VERSION]
#define USERTIMELINE_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/user_timeline.json", API_VERSION]
#define MENTIONS_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/mentions_timeline.json", API_VERSION]
#define FAVORITES_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/list.json", API_VERSION]
#define SEARCH_URL [NSString stringWithFormat:@"https://api.twitter.com/%@/search/tweets.json", API_VERSION]
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

+ (NSString *)getRequestURL:(FPTGetRequestType)getRequestType;
+ (NSString *)postRequestURL:(FPTGetRequestType)postRequestType parameters:(NSDictionary *)parameters;

+ (NSString *)getRequestNotificationName:(FPTGetRequestType)getRequestType;
+ (NSString *)postRequestNotificationName:(FPTGetRequestType)postRequestType;

+ (oneway void)postAPIErrorNotificationName:(NSString *)notificationName;
+ (oneway void)postAPIErrorNotificationName:(NSString *)notificationName userInfo:(id)userInfo;

@end

@implementation FPTRequest

#pragma mark - GET
+ (oneway void)requestWithGetType:(FPTGetRequestType)getRequestType parameters:(NSDictionary *)parameters {
    
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
        
        NSString *requestURL = [self getRequestURL:getRequestType];
        __block NSString *notificationName = [self getRequestNotificationName:getRequestType];
        
        if ( [requestURL isEmpty] ||
             [notificationName isEmpty] ) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [ShowAlert error:@"RequestError"];
                [FPTRequest postAPIErrorNotificationName:GET_API_ERROR_NOTIFICATION];
            });
            return;
        }
        
        NSLog(@"requestURL: %@", requestURL);
        
        FPTRequest *request = (FPTRequest *)[FPTRequest requestForServiceType:SLServiceTypeTwitter
                                                                requestMethod:TWRequestMethodGET
                                                                          URL:[NSURL URLWithString:requestURL]
                                                                   parameters:parameters];
        
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
                
//                NSString *responseString = [[[NSString alloc] initWithData:responseData
//                                                                  encoding:NSUTF8StringEncoding] autorelease];
                
                if ( [responseData isEmpty] ) {
                    
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
                        
                        tweetDataArray = [tweetData objectForKey:@"statuses"];
                        
                    } else {
                        
                        tweetDataArray = (NSArray *)tweetData;
                    }
                
                    if ( timelineListMode ) {
                        
                        notificationName = [self getRequestNotificationName:FPTGetRequestTypeHomeTimeline];
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
                        
                        NSMutableDictionary *userInfo = [@{RESPONSE_DATA : convertedTweets,
                                                         REQUEST_USER_NAME : request.account.username} mutableCopy];
                        
                        if ( getRequestType == FPTGetRequestTypeSearch ) {
                            
                            [userInfo setObject:parameters[@"q"]
                                         forKey:@"SearchWord"];
                        }
                        
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

+ (NSString *)getRequestURL:(FPTGetRequestType)getRequestType {
    
    return @[
             HOMETIMELINE_URL, USERTIMELINE_URL, MENTIONS_URL,
             FAVORITES_URL, SEARCH_URL, TWEET_URL,
             PROFILE_URL, LISTS_LIST_URL, LIST_URL
             ][getRequestType];
}

+ (NSString *)postRequestURL:(FPTGetRequestType)postRequestType parameters:(NSDictionary *)parameters {
    
    return @[
             POST_URL, POST_WITH_MEDIA_URL, FAVORITE_URL,
             UN_FAVORITE_URL, RETWEET_URL, DESTROY_URL
             ][postRequestType];
}

#pragma mark - POST
+ (oneway void)requestWithPostType:(FPTPostRequestType)postRequestType parameters:(NSDictionary *)parameters {
    
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
        
        NSString *requestURL = [self postRequestURL:postRequestType
                                         parameters:parameters];
        NSString *notificationName = [self postRequestNotificationName:postRequestType];
        NSData *imageData = nil;
        BOOL withMedia = NO;
        
        if ( postRequestType == FPTPostRequestTypeTextWithMedia ) {
            
            imageData = parameters[@"image"];
            
            if ( imageData == nil ) {
                
                postRequestTypeTemp = FPTPostRequestTypeText;
                
            } else {
                
                withMedia = YES;
            }
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
        
        if ( postRequestType == FPTPostRequestTypeText ||
             postRequestType == FPTPostRequestTypeTextWithMedia ) {
        
            status = parameters[@"status"];
            inReplyToID = parameters[@"in_reply_to_status_id"];
            
            NSDictionary *saveTweet = @{@"UserName" : [TWAccounts currentAccountName],
                                        @"Parameters" : parameters};
            
            [[[TWTweets manager] sendedTweets] addObject:saveTweet];
        }
        
        NSMutableDictionary *sendParameters = nil;
        if ( withMedia ) {
            
            sendParameters = [parameters mutableCopy];
            [sendParameters removeObjectForKey:@"image"];
            
        } else {
            
            sendParameters = [parameters mutableCopy];
        }
        
        FPTRequest *request = (FPTRequest *)[FPTRequest requestForServiceType:SLServiceTypeTwitter
                                                                requestMethod:TWRequestMethodPOST
                                                                          URL:[NSURL URLWithString:requestURL]
                                                                   parameters:sendParameters];
        
        if ( needSelectAccount ) {
            
            [request setAccount:[TWAccounts selectAccount:index]];
            
        } else {
            
            [request setAccount:[TWAccounts currentAccount]];
        }
        
        if ( withMedia ) {
            
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"multipart/form-data"
                             filename:@"image"];
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
                
//                NSString *responseString = [[NSString alloc] initWithData:responseData
//                                                                 encoding:NSUTF8StringEncoding];
                
                if ( [responseData isEmpty] ) {
                    
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
                        NSString *sendedText = [TWTweetUtility openTco:tweet.text
                                                          fromEntities:tweet.entities];
                        
                        NSDictionary *userInfo = @{@"SendedText" : sendedText,
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

+ (NSString *)getRequestNotificationName:(FPTGetRequestType)getRequestType {
    
    return @[
             HOME_TIMELINE_DONE_NOTIFICATION, USER_TIMELINE_DONE_NOTIFICATION, MENTIONS_DONE_NOTIFICATION,
             FAVORITES_DONE_NOTIFICATION, SEARCH_DONE_NOTIFICATION, TWEET_DONE_NOTIFICATION,
             PROFILE_DONE_NOTIFICATION, LISTS_LIST_DONE_NOTIFICATION, LIST_DONE_NOTIFICATION
             ][getRequestType];
}

+ (NSString *)postRequestNotificationName:(FPTGetRequestType)postRequestType {
    
    return @[
             POST_DONE_NOTIFICATION, POST_WITH_MEDIA_DONE_NOTIFICATION, FAVORITE_DONE_NOTIFICATION,
             UN_FAVORITE_DONE_NOTIFICATION, RETWEET_DONE_NOTIFICATION, DESTORY_DONE_NOTIFICATION
             ][postRequestType];
}

#pragma mark - Util
+ (NSString *)usingAPIVersion {
    
    return API_VERSION;
}

+ (oneway void)postAPIErrorNotificationName:(NSString *)notificationName {
    
    [FPTRequest postAPIErrorNotificationName:notificationName
                                    userInfo:nil];
}

+ (oneway void)postAPIErrorNotificationName:(NSString *)notificationName userInfo:(id)userInfo {
    
    [NSNotificationCenter postNotificationCenterForName:notificationName
                                           withUserInfo:userInfo ? @{@"ErrorResponseData" : userInfo} : nil];
}

@end

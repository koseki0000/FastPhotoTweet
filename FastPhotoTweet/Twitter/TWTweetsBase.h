//
//  TWTweetsBase.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import <Foundation/Foundation.h>
#import "TWAccounts.h"

@interface TWTweetsBase : NSObject

@property (retain, nonatomic) NSMutableDictionary *timelines;
@property (retain, nonatomic) NSMutableDictionary *sinceIDs;

@property (retain, nonatomic) NSMutableArray *sendedTweets;

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *inReplyToID;
@property (copy, nonatomic) NSString *tabChangeFunction;

@property (retain, nonatomic) NSArray *lists;
@property (copy, nonatomic) NSString *listID;
@property (copy, nonatomic) NSString *showingListID;

+ (TWTweetsBase *)manager;

@end

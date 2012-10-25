//
//  TWList.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import "ActivityIndicator.h"
#import "ShowAlert.h"
#import "RegularExpression.h"
#import "TWEntities.h"
#import "TWAccounts.h"

@interface TWList : NSObject

+ (oneway void)getListAll;
+ (oneway void)getList:(NSString *)listId;

@end

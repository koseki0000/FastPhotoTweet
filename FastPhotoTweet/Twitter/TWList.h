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
#import "TWEntities.h"
#import "TWAccounts.h"
#import "NSString+RegularExpression.h"

@interface TWList : NSObject

+ (oneway void)getListAll;
+ (oneway void)getList:(NSString *)listId;

@end

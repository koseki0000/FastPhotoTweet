//
//  TWList.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import "TWGetAccount.h"
#import "ActivityIndicator.h"
#import "ShowAlert.h"
#import "RegularExpression.h"
#import "TWEntities.h"

@interface TWList : NSObject

+ (void)getListAll;
+ (void)getList:(NSString *)listId;

@end

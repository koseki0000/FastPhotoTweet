//
//  TWNgTweet.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

#import <Foundation/Foundation.h>
#import "TWParser.h"
#import "TWEntities.h"
#import "RegularExpression.h"
#import "EmptyCheck.h"
#import "DeleteWhiteSpace.h"
#import "ArrayDuplicate.h"
#import "TWAccounts.h"

@interface TWNgTweet : NSObject

+ (NSArray *)ngWord:(NSArray *)tweets;
+ (NSArray *)ngName:(NSArray *)tweets;
+ (NSArray *)ngClient:(NSArray *)tweets;

+ (id)ngAll:(id)tweets;

@end

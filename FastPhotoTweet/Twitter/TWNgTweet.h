//
//  TWNgTweet.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

#import <Foundation/Foundation.h>
#import "TWGetAccount.h"
#import "TWParser.h"
#import "RegularExpression.h"
#import "EmptyCheck.h"
#import "DeleteWhiteSpace.h"

@interface TWNgTweet : NSObject

+ (NSArray *)ngWord:(NSArray *)tweets;
+ (NSArray *)ngName:(NSArray *)tweets;
+ (NSArray *)ngClient:(NSArray *)tweets;

@end

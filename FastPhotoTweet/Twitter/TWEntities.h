//
//  TWEntities.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "TWParser.h"
#import "EmptyCheck.h"

@interface TWEntities : NSObject

+ (NSString *)openTco:(NSDictionary *)tweet;
+ (NSString *)openTcoWithReTweet:(NSDictionary *)tweet;
+ (NSDictionary *)replaceTco:(NSDictionary *)tweet;
+ (NSMutableString *)replace:(NSDictionary *)tweet text:(NSMutableString *)text entitiesType:(NSString *)entitiesType;

+ (NSMutableArray *)replaceTcoAll:(NSMutableArray *)tweets;

@end

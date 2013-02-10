//
//  TWTweetEntities.m
//

#import "TWTweetEntities.h"

@implementation TWTweetEntities

+ (TWTweetEntities *)entitiesWithDictionary:(NSDictionary *)tweet {
    
//    NSLog(@"%s", __func__);
    
    TWTweetEntities *entities = [[TWTweetEntities alloc] init];
    NSMutableArray *urls = [NSMutableArray array];
    
    for ( id URL in tweet[@"entities"][@"urls"] ) {
        
        [urls addObject:URL];
    }
    
    for ( id mediaURL in tweet[@"entities"][@"media"] ) {
        
        [urls addObject:mediaURL];
    }
    
    [entities setUrls:urls];
    
    return entities;
}

+ (TWTweetEntities *)rtEntitiesWithDictionary:(NSDictionary *)tweet {
    
//    NSLog(@"%s", __func__);
    
    NSMutableArray *urls = [NSMutableArray array];
    
    for ( id URL in tweet[@"retweeted_status"][@"entities"][@"urls"] ) {
        
        [urls addObject:URL];
    }
    
    for ( id mediaURL in tweet[@"retweeted_status"][@"entities"][@"media"] ) {
        
        [urls addObject:mediaURL];
    }
    
    TWTweetEntities *entities = [[TWTweetEntities alloc] init];
    [entities setUrls:urls];
    [entities setUserMentions:tweet[@"retweeted_status"][@"entities"][@"user_mentions"]];
    
    return entities;
}

@end

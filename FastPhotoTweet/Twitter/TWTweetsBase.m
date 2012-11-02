//
//  TWTweetsBase.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweetsBase.h"

@implementation TWTweetsBase

static TWTweetsBase *sharedObject = nil;

+ (TWTweetsBase *)manager {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [[self alloc] init];
        });
    }
    
    return sharedObject;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            sharedObject = [super allocWithZone:zone];
            
            sharedObject.timelines = [NSMutableDictionary dictionary];
            [sharedObject.timelines retain];
            
            sharedObject.sinceIDs = [NSMutableDictionary dictionary];
            [sharedObject.sinceIDs retain];
            
            for ( ACAccount *account in [TWAccountsBase manager].twitterAccounts ) {
                
                [sharedObject.timelines setObject:[NSMutableArray array] forKey:account.username];
                [sharedObject.sinceIDs setObject:[NSDictionary dictionary] forKey:account.username];
            }
        });
        
        return sharedObject;
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (id)retain {
    
    return self;
}

- (unsigned)retainCount {
    
    return UINT_MAX;
}

- (oneway void)release {
    
}

- (id)autorelease {
    
    return self;
}

- (void)dealloc {
    
    [self setTimelines:nil];
    [self setSinceIDs:nil];
    
    [super dealloc];
}

@end

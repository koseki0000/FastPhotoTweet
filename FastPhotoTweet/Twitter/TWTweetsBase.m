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
    
    @synchronized(self) {
        
        if ( sharedObject == nil ) {
            
            [[self alloc] init];
        }
    }
    
    return sharedObject;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self) {
        
        if ( sharedObject == nil ) {
            
            sharedObject = [super allocWithZone:zone];
            
            sharedObject.timelines = [NSMutableDictionary dictionary];
            [sharedObject.timelines retain];
            
            sharedObject.sinceIDs = [NSMutableDictionary dictionary];
            [sharedObject.sinceIDs retain];
            
            for ( ACAccount *account in [TWAccountsBase manager].twitterAccounts ) {
                
                [sharedObject.timelines setObject:[NSMutableArray array] forKey:account.username];
                [sharedObject.sinceIDs setObject:@"" forKey:account.username];
            }
            
            return sharedObject;
        }
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

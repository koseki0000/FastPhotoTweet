//
//  TWAccountsBase.m
//

#import "TWAccountsBase.h"

@interface TWAccountsBase ()

@property (retain, readwrite) NSArray *twitterAccounts;

@end

@implementation TWAccountsBase

static TWAccountsBase *sharedObject = nil;

+ (id)manager {
    
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
            sharedObject.twitterAccounts = [TWAccountsBase getTwitterAccounts];
            [sharedObject.twitterAccounts retain];
            
            return sharedObject;
        }
    }
    
    return nil;
}

+ (NSArray *)getTwitterAccounts {
 
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twAccounts = [store accountsWithAccountType:type];
    
    return twAccounts;
}

- (id)copyWithZone:(NSZone*)zone {
    
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
    
    [self setTwitterAccounts:nil];
    
    [super dealloc];
}

@end

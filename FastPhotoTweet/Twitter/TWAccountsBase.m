//
//  TWAccountsBase.m
//

#import "TWAccountsBase.h"

@interface TWAccountsBase ()

@property (retain, readwrite) NSArray *twitterAccounts;

@end

@implementation TWAccountsBase

static TWAccountsBase *sharedObject = nil;

+ (TWAccountsBase *)manager {
    
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
            [TWAccountsBase getTwitterAccounts];
        });
        
        return sharedObject;
    }
    
    return nil;
}

+ (void)getTwitterAccounts {
    
    NSLog(@"getTwitterAccounts");
 
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    sharedObject.twitterAccounts = [store accountsWithAccountType:type];
    [sharedObject.twitterAccounts retain];
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
    
    [self setTwitterAccounts:nil];
    
    [super dealloc];
}

@end

//
//  TWAccounts.m
//

#import "TWAccounts.h"

@interface TWAccounts ()

@property (nonatomic, strong) ACAccountStore *store;

+ (void)getTwitterAccounts;

@end

@implementation TWAccounts

static TWAccounts *sharedObject = nil;

+ (TWAccounts *)manager {
    
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
            [TWAccounts getTwitterAccounts];
        });
        
        return sharedObject;
    }
    
    return nil;
}

+ (void)getTwitterAccounts {
    
    NSLog(@"getTwitterAccounts");
    
    [[TWAccounts manager] setStore:[[[ACAccountStore alloc] init] autorelease]];
    ACAccountType *type = [[[TWAccounts manager] store] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [[TWAccounts manager] setTwitterAccounts:[[[TWAccounts manager] store] accountsWithAccountType:type]];
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

//////////////////////////////////////

+ (NSArray *)twitterAccounts {
    
    return [[TWAccounts manager] twitterAccounts];
}

+ (ACAccount *)currentAccount {
    
    NSArray *accounts = [[TWAccounts manager] twitterAccounts];
    
    if ( accounts != nil &&
         accounts.count != 0 ) {
     
        return [accounts objectAtIndex:[USER_DEFAULTS integerForKey:@"UseAccount"]];
        
    } else {
        
        return nil;
    }
}

+ (NSString *)currentAccountName {
    
    NSArray *accounts = [[TWAccounts manager] twitterAccounts];
    
    if ( accounts != nil &&
         accounts.count != 0 ) {
        
        ACAccount *account = [accounts objectAtIndex:[USER_DEFAULTS integerForKey:@"UseAccount"]];
        
        return [account username];
        
    } else {
        
        return @"";
    }
}

+ (ACAccount *)selectAccount:(NSInteger)index {
    
    @try {

        NSUInteger accountCount = [TWAccounts accountCount];
        
        if ( accountCount > 0 && accountCount - 1 >= index ) {
            
            return [[TWAccounts twitterAccounts] objectAtIndex:index];
            
        } else {
            
            return nil;
        }
        
    }@catch ( NSException *e ) {
        
        return nil;
    }
}

+ (NSUInteger)accountCount {
    
    return [[[TWAccounts manager] twitterAccounts] count];
}

@end

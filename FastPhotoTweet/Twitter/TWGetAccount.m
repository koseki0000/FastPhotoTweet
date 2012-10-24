//
//  TWGetAccount.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWGetAccount.h"

@implementation TWGetAccount

+ (ACAccount *)currentAccount {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    
    @try {
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        
        if ( twitterAccounts.count > 0 ) {
            
            return [twitterAccounts objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]];
            
        }else {
        
            return nil;
        }
    
    }@catch ( NSException *e ) {
        
        return nil;
    }
}

+ (ACAccount *)selectAccount:(int)num {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    
    @try {
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        
        if ( twitterAccounts.count > 0 && twitterAccounts.count - 1 >= num ) {
            
            return [twitterAccounts objectAtIndex:num];
            
        }else {
            
            return nil;
        }
        
    }@catch (NSException *e) {
    
        return nil;
    }
}

+ (int)getCount {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    
    return twitterAccounts.count;
}

+ (NSArray *)accounts {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    
    return twitterAccounts;
}

@end

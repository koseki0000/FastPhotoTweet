//
//  TWGetAccount.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWGetAccount.h"

@implementation TWGetAccount

+ (ACAccount *)currentAccount {
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    
    if ( twitterAccounts.count > 0 ) {
        
        //NSLog(@"Account Success");
        
        return [twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]];
    }
    
    //NSLog(@"%@", twAccount.username);
    
    return nil;
}

+ (ACAccount *)selectAccount:(int)num {
    
    ACAccount *twAccount = [[[ACAccount alloc] init] autorelease];
    
    @try {
        
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        
        if ( twitterAccounts.count > 0 && twitterAccounts.count - 1 >= num ) {
            
            twAccount = [twitterAccounts objectAtIndex:num];
        }
        
    }@catch ( NSException *e ) { return nil; }
    
    return twAccount;
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
    
    //NSLog(@"twitterAccounts: %@", twitterAccounts);
    
    return twitterAccounts;
}

@end

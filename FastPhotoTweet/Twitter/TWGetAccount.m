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
    ACAccount *twAccount = [[[ACAccount alloc] init] autorelease];
    
    if ( twitterAccounts.count > 0 ) {
        
        //NSLog(@"Account Success");
        
        twAccount = [twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]];
        
    }else {
        
        //NSLog(@"Account Error");
    }
    
    //NSLog(@"%@", twAccount.username);
    
    return twAccount;
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
        
    }@catch ( NSException *e ) {}
    
    return twAccount;
}

+ (int)getCount {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    
    return twitterAccounts.count;
}

@end

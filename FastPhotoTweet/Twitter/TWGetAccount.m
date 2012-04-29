//
//  TWGetAccount.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWGetAccount.h"

@implementation TWGetAccount

+ (ACAccount *)getTwitterAccount {
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *twAccount = [[[ACAccount alloc] init] autorelease];
    twAccount = nil;
    
    if (twitterAccounts.count > 0) {
        
        //NSLog(@"Account Success");
        
        twAccount = [twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]];
        
    }else {
        
        //NSLog(@"Account Error");
    }
    
    return twAccount;
}

+ (ACAccount *)getTwitterAccount:(int)num {
    
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *twAccount = [[[ACAccount alloc] init] autorelease];
    twAccount = nil;
    
    if (twitterAccounts.count > 0) {
        
        //NSLog(@"Account Success");
        
        twAccount = [twitterAccounts objectAtIndex:num];
        
    }else {
        
        //NSLog(@"Account Error");
    }
    
    return twAccount;
}

@end

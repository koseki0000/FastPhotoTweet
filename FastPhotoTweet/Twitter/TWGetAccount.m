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
    ACAccount *twAccount = [[[ACAccount alloc] init] autorelease];
    twAccount = nil;
    
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    if (twitterAccounts.count > 0) {
        
        NSLog(@"Account Success");
        
        twAccount = [twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]];
        
    }else {
        
        NSLog(@"Account Error");
    }
    
    return twAccount;
}

@end
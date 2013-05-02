//
//  TWAccounts.m
//

#import "TWAccounts.h"

@implementation TWAccounts

+ (TWAccounts *)manager {
    
    return (TWAccounts *)[TWAccountsBase manager];
}

+ (NSArray *)twitterAccounts {
    
    return ((TWAccounts *)[TWAccountsBase manager]).twitterAccounts;
}

+ (ACAccount *)currentAccount {
    
    NSArray *accounts = [TWAccountsBase manager].twitterAccounts;
    
    if ( accounts != nil &&
         accounts.count != 0 ) {
     
        return [accounts objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]];
        
    }else {
        
        return nil;
    }
}

+ (NSString *)currentAccountName {
    
    NSArray *accounts = [TWAccountsBase manager].twitterAccounts;
    
    if ( accounts != nil &&
         accounts.count != 0 ) {
        
        return ((ACAccount *)[accounts objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]]).username;
        
    }else {
        
        return @"";
    }
}

+ (ACAccount *)selectAccount:(NSInteger)index {
    
    @try {

        NSUInteger accountCount = [TWAccounts accountCount];
        
        if ( accountCount > 0 && accountCount - 1 >= index ) {
            
            return [[TWAccounts twitterAccounts] objectAtIndex:index];
            
        }else {
            
            return nil;
        }
        
    }@catch ( NSException *e ) {
        
        return nil;
    }
}

+ (NSUInteger)accountCount {
    
    return ((TWAccounts *)[TWAccountsBase manager]).twitterAccounts.count;
}

@end

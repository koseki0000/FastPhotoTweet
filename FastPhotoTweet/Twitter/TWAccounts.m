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
    return [((TWAccounts *)[TWAccountsBase manager]).twitterAccounts objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]];
}

+ (ACAccount *)selectAccount:(int)num {
    
    @try {

        NSUInteger accountCount = [TWAccounts accountCount];
        
        if ( accountCount > 0 && accountCount - 1 >= num ) {
            
            return [[TWAccounts twitterAccounts] objectAtIndex:num];
            
        }else {
            
            return nil;
        }
        
    }@catch (NSException *e) {
        
        return nil;
    }
}

+ (NSUInteger)accountCount {
    
    return ((TWAccounts *)[TWAccountsBase manager]).twitterAccounts.count;
}

@end

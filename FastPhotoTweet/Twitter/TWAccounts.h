//
//  TWAccounts.h
//

#import "TWAccountsBase.h"

@interface TWAccounts : TWAccountsBase

+ (TWAccounts *)manager;
+ (NSArray *)twitterAccounts;
+ (ACAccount *)currentAccount;
+ (ACAccount *)selectAccount:(int)num;
+ (NSUInteger)accountCount;

@end

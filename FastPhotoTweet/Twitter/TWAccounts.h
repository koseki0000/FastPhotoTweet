//
//  TWAccounts.h
//

#import "TWAccountsBase.h"

@interface TWAccounts : TWAccountsBase

+ (TWAccounts *)manager;
+ (NSArray *)twitterAccounts;
+ (ACAccount *)currentAccount;
+ (NSString *)currentAccountName;
+ (ACAccount *)selectAccount:(int)num;
+ (NSUInteger)accountCount;

@end

//
//  TWAccounts.h
//

#import "TWAccountsBase.h"

@interface TWAccounts : TWAccountsBase

+ (TWAccounts *)manager;
+ (NSArray *)twitterAccounts;
+ (ACAccount *)currentAccount;
+ (NSString *)currentAccountName;
+ (ACAccount *)selectAccount:(NSInteger)index;
+ (NSUInteger)accountCount;

@end

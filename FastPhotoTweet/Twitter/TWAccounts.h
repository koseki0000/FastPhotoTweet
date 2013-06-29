//
//  TWAccounts.h
//

#import <Accounts/Accounts.h>

@interface TWAccounts : NSObject

@property (nonatomic, retain) NSArray *twitterAccounts;

+ (TWAccounts *)manager;
+ (NSArray *)twitterAccounts;
+ (ACAccount *)currentAccount;
+ (NSString *)currentAccountName;
+ (ACAccount *)selectAccount:(NSInteger)index;
+ (NSUInteger)accountCount;

@end

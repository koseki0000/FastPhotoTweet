//
//  TWAccountsBase.h
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface TWAccountsBase : NSObject

@property (retain, readonly) NSArray *twitterAccounts;

+ (id)manager;
+ (NSArray *)getTwitterAccounts;

@end
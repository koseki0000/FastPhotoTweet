//
//  CheckAppVersion.h
//  FastPhotoTweet
//
//  Created by 日暮佑貴 on 2013/05/28.
//
//

#import <Foundation/Foundation.h>

@interface CheckAppVersion : NSObject <UIAlertViewDelegate>

- (oneway void)versionInfoURL:(NSString *)versionInfoURL updateIpaURL:(NSString *)updateIpaURL;

@end

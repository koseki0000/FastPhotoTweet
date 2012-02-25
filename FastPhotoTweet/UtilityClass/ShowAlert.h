//
//  ShowAlert.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/11/10.
//

#import <Foundation/Foundation.h>

@interface ShowAlert : UIAlertView

- (void)title:(NSString *)title message:(NSString *)message;
- (void)noTitle:(NSString *)message;
- (void)error:(NSString *)message;

@end

//
//  ShowAlert.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/11/10.
//

#import "ShowAlert.h"

@implementation ShowAlert

- (void)title:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = title;
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
}

- (void)noTitle:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
}

- (void)error:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"Error";
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //Twitterアカウントエラーの場合は設定に飛ばす
    if ( [alertView.message isEqualToString:@"Twitter account nothing"] ||
         [alertView.message isEqualToString:@"Twitter account access denied"] ) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
        
    }
    
}

@end

//
//  ShowAlert.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/11/10.
//

#import "ShowAlert.h"

@implementation ShowAlert

+ (void)title:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    alert.delegate = self;
    alert.title = title;
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

+ (void)noTitle:(NSString *)message {
    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    alert.delegate = self;
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

+ (void)error:(NSString *)message {
    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    alert.delegate = self;
    alert.title = @"Error";
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

+ (void)unknownError {
    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    alert.delegate = self;
    alert.title = @"Error";
    alert.message = @"不明なエラーが発生しました。";
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    [self release];
}

- (void)dealloc {
    
    //NSLog(@"ShowAlert dealloc");
    
    [super dealloc];
}

@end

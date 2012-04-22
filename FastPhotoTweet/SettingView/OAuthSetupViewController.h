//
//  OAuthSetupViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/21.
//

#import <UIKit/UIKit.h>
#import "FBEncryptorAES.h"
#import "OAuthConsumer.h"
#import "ShowAlert.h"
#import "GrayView.h"
#import "EmptyCheck.h"
#import "ActivityIndicator.h"

@interface OAuthSetupViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
    
    OAConsumer *consumer;
    GrayView *grayView;
}

@property (retain, nonatomic) IBOutlet UINavigationItem *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITextField *pinField;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (retain, nonatomic) IBOutlet UIWebView *wv;

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)oaRequestStart;
- (void)setPinCode;
- (void)finish;
- (void)enableButton;

- (IBAction)pushCloseButton:(id)sender;
- (IBAction)pushDoneButton:(id)sender;

@end

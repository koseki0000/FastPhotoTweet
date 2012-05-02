//
//  WebViewExController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "WebViewEx.h"
#import "UtilityClass.h"

@interface WebViewExController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
    
    AppDelegate *appDelegate;
    WebViewEx *wv;
    
    NSUserDefaults *d;
    NSString *accessURL;
    
    int actionSheetNo;
}

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITextField *urlField;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (retain, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;

- (IBAction)pushSearchButton:(id)sender;
- (IBAction)pushCloseButton:(id)sender;
- (IBAction)pushReloadButton:(id)sender;
- (IBAction)pushBackButton:(id)sender;
- (IBAction)pushForwardButton:(id)sender;
- (IBAction)pushComposeButton:(id)sender;
- (IBAction)pushMenuButton:(id)sender;

- (IBAction)enterSearchField:(id)sender;
- (IBAction)enterURLField:(id)sender;

- (IBAction)onUrlField: (id)sender;
- (IBAction)leaveUrlField: (id)sender;

- (IBAction)onSearchField: (id)sender;
- (IBAction)leaveSearchField: (id)sender;

- (void)becomeActive:(NSNotification *)notification;
- (void)setSearchEngine;
- (void)updateWebBrowser;
- (void)backForwordButtonVisible;

@end

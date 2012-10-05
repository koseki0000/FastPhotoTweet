//
//  WebViewExController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WebViewEx.h"
#import "UtilityClass.h"
#import "DeleteWhiteSpace.h"
#import "BookmarkViewController.h"
#import "InternetConnection.h"
#import "ADBlock.h"

@interface WebViewExController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, NSXMLParserDelegate> {
    
    AppDelegate *appDelegate;
    GrayView *grayView;

    UIPasteboard *pboard;
    UIAlertView *alert;
    UITextField *alertText;
    UIImage *reloadButtonImage;
    UIImage *stopButtonImage;
    
    NSUserDefaults *d;
    NSString *accessURL;
    NSString *loadStartURL;
    NSString *saveFileName;
    NSString *downloadUrl;
    NSURLConnection *asyncConnection;
    NSMutableData *asyncData;
    NSArray *startupUrlList;
    NSArray *urlList;
    
    float totalbytes;
    float loadedbytes;
    
    int retina4InchOffset;
    int actionSheetNo;
    int alertTextNo;
    
    BOOL showActionSheet;
    BOOL openBookmark;
    BOOL fullScreen;
    BOOL editing;
    BOOL downloading;
    BOOL loading;
}

@property (retain, nonatomic) IBOutlet WebViewEx *wv;

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
@property (retain, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;

@property (retain, nonatomic) IBOutlet UILabel *bytesLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (retain, nonatomic) IBOutlet UIButton *downloadCancelButton;

- (IBAction)pushSearchButton:(id)sender;
- (IBAction)pushCloseButton:(id)sender;
- (IBAction)pushReloadButton:(id)sender;
- (IBAction)pushBackButton:(id)sender;
- (IBAction)pushForwardButton:(id)sender;
- (IBAction)pushComposeButton:(id)sender;
- (IBAction)pushMenuButton:(id)sender;
- (IBAction)pushDownloadCancelButton:(id)sender;
- (IBAction)pushBookmarkButton:(id)sender;

- (IBAction)enterSearchField:(id)sender;
- (IBAction)enterURLField:(id)sender;

- (IBAction)onUrlField: (id)sender;
- (IBAction)leaveUrlField: (id)sender;
- (IBAction)onSearchField: (id)sender;
- (IBAction)leaveSearchField: (id)sender;

- (IBAction)fullScreenGesture:(id)sender;

- (IBAction)doubleTapUrlField:(id)sender;

- (void)selectOpenUrl;
- (void)selectUrl;

- (void)pboardNotification:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;
- (void)setSearchEngine;
- (void)updateWebBrowser;
- (void)backForwordButtonVisible;
- (void)reloadStopButton;
- (void)rotateView:(int)mode;
- (void)saveImage;
- (void)requestStart:(NSString *)url;
- (void)selectDownloadUrl;
- (void)endDownload;
- (void)showDownloadMenu:(NSString *)url;
- (void)resetUserAgent;
- (void)adBlock;
- (void)setViewSize;

@end

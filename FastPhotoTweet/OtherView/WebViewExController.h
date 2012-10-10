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

@property (weak, nonatomic) IBOutlet WebViewEx *wv;
@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (weak, nonatomic) IBOutlet UILabel *bytesLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadCancelButton;

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

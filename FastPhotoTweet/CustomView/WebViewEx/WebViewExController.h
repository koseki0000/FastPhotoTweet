//
//  WebViewExController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import "AppDelegate.h"
#import "WebViewEx.h"
#import "UtilityClass.h"
#import "DeleteWhiteSpace.h"
#import "BookmarkViewController.h"
#import "InternetConnection.h"
#import "ADBlock.h"
#import "UIViewSubViewRemover.h"
#import "SSTextField.h"
#import "NSString+WordCollect.h"
#import "NSString+RegularExpression.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import <CFNetwork/CFNetwork.h>

@interface WebViewExController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, NSXMLParserDelegate> {
    
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

@property (retain, nonatomic) GrayView *grayView;

@property (retain, nonatomic) UIAlertView *alert;
@property (retain, nonatomic) UITextField *alertText;
@property (retain, nonatomic) UIImage *reloadButtonImage;
@property (retain, nonatomic) UIImage *stopButtonImage;

@property (copy, nonatomic) NSString *accessURL;
@property (copy, nonatomic) NSString *loadStartURL;
@property (copy, nonatomic) NSString *saveFileName;
@property (copy, nonatomic) NSString *downloadUrl;
@property (retain, nonatomic) NSURLConnection *asyncConnection;
@property (retain, nonatomic) NSMutableData *asyncData;
@property (retain, nonatomic) NSArray *startupUrlList;
@property (retain, nonatomic) NSArray *urlList;

@property (strong, nonatomic) IBOutlet WebViewEx *wv;
@property (strong, nonatomic) IBOutlet UIToolbar *topBar;
@property (strong, nonatomic) IBOutlet SSTextField *urlField;
@property (strong, nonatomic) IBOutlet SSTextField *searchField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (strong, nonatomic) IBOutlet UILabel *bytesLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *downloadCancelButton;

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

//
//  WebViewEx.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import <UIKit/UIWebView.h>
#import "ShowAlert.h"
#import "RegularExpression.h"
#import "DeleteWhiteSpace.h"
#import "EmptyCheck.h"

@interface WebViewEx : UIWebView {
    
    int x;
    int y;
    int w;
    int h;
    int viewSize;
    
    BOOL isInit;
}

@property (retain, nonatomic) NSURL *URL;
@property (retain, nonatomic) NSURLRequest *URLReq;

- (id)initWithSizeZero;
- (id)initWithSizeFullScreenNoStatusBar;
- (id)initWithSizeFullScreen;
- (id)initWithSizeTopBarNoStatusBar;
- (id)initWithSizeTopBar;
- (id)initWithSizeBottomBarNoStatusBar;
- (id)initWithSizeBottomBar;
- (id)initWithSizeTopAndBottomBarNoStatusBar;
- (id)initWithSizeTopAndBottomBar;

- (void)setSize;
- (void)setSizeZero;
- (void)setSizeFullScreenNoStatusBar;
- (void)setSizeFullScreen;
- (void)setSizeTopBarNoStatusBar;
- (void)setSizeTopBar;
- (void)setSizeBottomBarNoStatusBar;
- (void)setSizeBottomBar;
- (void)setSizeTopAndBottomBarNoStatusBar;
- (void)setSizeTopAndBottomBar;

- (void)loadRequestWithString:(NSString *)URLString;
- (void)close;

- (NSString *)selectString;
- (NSString *)pageTitle;
- (NSString *)sourceCode;
- (NSString *)url;

@end

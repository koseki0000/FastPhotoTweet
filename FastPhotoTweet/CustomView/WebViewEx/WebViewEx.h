//
//  WebViewEx.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import <UIKit/UIWebView.h>
#import "ShowAlert.h"
#import "NSString+RegularExpression.h"
#import "NSString+WordCollect.h"
#import "EmptyCheck.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import <CFNetwork/CFNetwork.h>

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

- (void)loadRequestWithString:(NSString *)URLString;

- (NSString *)selectString;
- (NSString *)pageTitle;
- (NSString *)sourceCode;
- (NSString *)url;

@end

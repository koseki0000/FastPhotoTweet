//
//  WebViewEx.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "WebViewEx.h"

#define FIREFOX_USERAGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:22.0) Gecko/20100101 Firefox/22.0"
#define IPAD_USERAFENT    @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USERAGENT  @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_2 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B146 Safari/8536.25"

@implementation WebViewEx
@synthesize URL;
@synthesize URLReq;

//NSStringからloadRequest or URLScheme
- (void)loadRequestWithString:(NSString *)URLString {
    
    //NSLog(@"loadRequestWithString");
    
    if ( ![EmptyCheck string:URLString] ) {
        
        [ShowAlert error:@"URLがありません。"];
    }
    
    URL = [NSURL URLWithString:URLString];
    
    if ( [URLString boolWithRegExp:@"about:blank|https?://.*"] ) {
        
        //そのままアクセス出来そうなURL
        //NSLog(@"http(s) address");
        
        URLReq = [NSURLRequest requestWithURL:URL];
        [self loadRequest:URLReq];
        
    } else {
        
        NSLog(@"not http(s) address");
        
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
        
        if ( canOpen ) {
            
            //URLScheme
            NSLog(@"scheme");
        
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[UIApplication sharedApplication] openURL:URL];
            
        } else {
            
            //そのままアクセス出来なそうでURLSchemeでもない
            //http://を付けてみる
            NSLog(@"add protocol");
            
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
            URLReq = [NSURLRequest requestWithURL:URL];
            [self loadRequest:URLReq];
        }
    }
}

- (void)loadRequest:(NSURLRequest *)request {

    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:request.URL.absoluteURL];
    
    if ( [request.URL.absoluteString rangeOfString:@"pixiv.net"].location != NSNotFound ) {
        
        [mRequest setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
        [mRequest setHTTPShouldHandleCookies:NO];
    }
    
    [super loadRequest:mRequest];
}

//選択中の文字が返される
- (NSString *)selectString {
    
    return [self stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"].deleteWhiteSpace;
}

//開いているページのタイトルが返される
- (NSString *)pageTitle {
    
    //NSLog(@"pageTitle");
    
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"].deleteWhiteSpace;
}

//開いているページのソースコードが返される
- (NSString *)sourceCode {
    
    NSString *sourceCodeString = @"";
    NSError *error = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.request URL] absoluteString]]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:nil 
                                                         error:&error];
    
    int encodingList[] = {
        
        NSUTF8StringEncoding,			// UTF-8
        NSShiftJISStringEncoding,		// Shift_JIS
        NSJapaneseEUCStringEncoding,	// EUC-JP
        NSISO2022JPStringEncoding,		// JIS
        NSUnicodeStringEncoding,		// Unicode
        NSASCIIStringEncoding			// ASCII
    };
    
    NSString *dataStr = nil;
    int max = sizeof( encodingList ) / sizeof( encodingList[0] );
    
    for ( int i = 0; i < max; i++ ) {
        
        dataStr = [[NSString alloc] initWithData:response encoding:encodingList[i]];
        
        if ( dataStr != nil ) {
            
            break;
        }
    }
    
    if ( error ) {
        
        [ShowAlert error:error.localizedDescription];
    }
    
    return sourceCodeString;
}

//アクセスしているURLを返す
- (NSString *)url {
    
    return self.request.URL.absoluteString;
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    
    //メモリキャッシュの削除
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
}

@end

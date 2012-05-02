//
//  WebViewEx.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import "WebViewEx.h"

//WebViewExをautoreleaseで生成するか
//autoreleaseで生成しない場合はNO
#define AUTORELEASE YES

#define STATUS_BAR 20
#define TOOL_BAR 44

#define IPHONE_WIDTH 320
#define IPHONE_HEIGHT 480
#define IPHONE_IAD_WIDTH 320
#define IPHONE_IAD_HEIGTH 50

#define IPAD_WIDTH 768
#define IPAD_HEIGHT 1024
#define IPAD_IAD_WIDTH 768
#define IPAD_IAD_HEIGTH 66

@implementation WebViewEx

- (id)initWithSizeZero {
    
    isInit = YES;
        
    [self setSizeZero];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeFullScreenNoStatusBar {
    
    isInit = YES;
    
    [self setSizeFullScreenNoStatusBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeFullScreen {
    
    isInit = YES;
    
    [self setSizeFullScreen];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeTopBarNoStatusBar {
    
    isInit = YES;
    
    [self setSizeTopBarNoStatusBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeTopBar {
    
    isInit = YES;
    
    [self setSizeTopBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeBottomBarNoStatusBar {
    
    isInit = YES;
    
    [self setSizeBottomBarNoStatusBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeBottomBar {
 
    isInit = YES;
    
    [self setSizeBottomBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeTopAndBottomBarNoStatusBar {
    
    isInit = YES;
    
    [self setSizeTopAndBottomBarNoStatusBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

- (id)initWithSizeTopAndBottomBar {
    
    isInit = YES;
    
    [self setSizeTopAndBottomBar];
    
    self = [super initWithFrame:CGRectMake( x, y, w, h ) ];
    
    if ( self ) {
    }
    
    return self;
}

//非表示
- (void)setSize {
    
    //NSLog(@"setSize");
    if ( !isInit ) {
        
        self.frame = CGRectMake(x, y, w, h);
        
    }else {
        
        isInit = NO;
    }
}

//非表示
- (void)setSizeZero {
    
    //NSLog(@"setSizeZero");
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    viewSize = 0;
    [self setSize];
}

//ステータスバー無し　フルスクリーン
- (void)setSizeFullScreenNoStatusBar {
    
    //NSLog(@"setSizeFullScreenNoStatusBar");
    x = 0;
    y = 0;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT;
    viewSize = 1;
    [self setSize];
}

//ステータスバーあり　フルスクリーン
- (void)setSizeFullScreen {
    
    //NSLog(@"setSizeFullScreen");
    x = 0;
    y = 0;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - STATUS_BAR;
    viewSize = 2;
    [self setSize];
}

//ステータスバー無し　上部にバー
- (void)setSizeTopBarNoStatusBar {
    
    //NSLog(@"setSizeTopBarNoStatusBar");
    x = 0;
    y = TOOL_BAR;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - TOOL_BAR;
    viewSize = 3;
    [self setSize];
}

//ステータスバーあり　上部にバー
- (void)setSizeTopBar {
    
    //NSLog(@"setSizeTopBar");
    x = 0;
    y = TOOL_BAR;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - STATUS_BAR - TOOL_BAR;
    viewSize = 4;
    [self setSize];
}

//ステータスバー無し　下部にバー
- (void)setSizeBottomBarNoStatusBar {
    
    //NSLog(@"setSizeBottomBarNoStatusBar");
    x = 0;
    y = 0;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - TOOL_BAR;
    viewSize = 5;
    [self setSize];
}

//ステータスバーあり　下部にバー
- (void)setSizeBottomBar {
    
    //NSLog(@"setSizeBottomBar");
    x = 0;
    y = 0;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - STATUS_BAR - TOOL_BAR;
    viewSize = 6;
    [self setSize];
}

//ステータスバー無し　上部と下部にバー
- (void)setSizeTopAndBottomBarNoStatusBar {
    
    //NSLog(@"setSizeTopAndBottomBarNoStatusBar");
    x = 0;
    y = TOOL_BAR;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - TOOL_BAR * 2;
    viewSize = 7;
    [self setSize];
}

//ステータスバーあり　上部と下部にバー
- (void)setSizeTopAndBottomBar {
    
    //NSLog(@"setSizeTopAndBottomBar");
    x = 0;
    y = TOOL_BAR;
    w = IPHONE_WIDTH;
    h = IPHONE_HEIGHT - STATUS_BAR - TOOL_BAR * 2;
    viewSize = 8;
    [self setSize];
}

//NSStringからloadRequest or URLScheme
- (void)loadRequestWithString:(NSString *)URLString {
    
    //NSLog(@"loadRequestWithString");
    
    if ( ![URLString isEqualToString:@""] && URLString != nil ) {
        
        URL = [NSURL URLWithString:URLString];
        
        if ( ![URLString hasPrefix:@"http"] ) {
            
            //NSLog(@"URLScheme");
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[[UIApplication sharedApplication] openURL:URL];
            
		}else {
            
            //NSLog(@"LoadRequest");
            URLReq = [NSURLRequest requestWithURL:URL];
            [self loadRequest:URLReq];   
        }
    }
}

//選択中の文字が返される
- (NSString *)selectString {
    
    //NSLog(@"selectString");
    
    return [self stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"];
}

//開いているページのタイトルが返される
- (NSString *)pageTitle {
    
    //NSLog(@"pageTitle");
    
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
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
        
        ShowAlert *errorAlert = [[ShowAlert alloc] init];
        [errorAlert error:error.localizedDescription];
    }
    
    return sourceCodeString;
}

//WebViewExを破棄する
- (void)close {
    
    NSLog(@"close");
    
    [self stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    self.delegate = nil;
    [self removeFromSuperview];
    
    if ( AUTORELEASE == NO ) {
        
        //NSLog(@"release");
        
        [self release];
    }
}

- (void)dealloc {
    
    NSLog(@"WebViewEx dealloc");
    
    [super dealloc];
}

@end

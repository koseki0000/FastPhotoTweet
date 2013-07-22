//
//  ImageWindow.m
//

#import "ImageWindow.h"
#import "UIImage+Convert.h"
#import "UIImage+GIF.h"

@interface ImageWindow ()

@property (nonatomic) CGAffineTransform currentTransForm;
@property (nonatomic) CGFloat scale;

@property (nonatomic, strong) NSValue *viewRect;
@property (nonatomic) CGFloat topMargin;
@property (nonatomic) CGFloat maxSize;
@property (nonatomic) CGFloat receivedSize;

@property (nonatomic) BOOL afterClose;
@property (nonatomic) BOOL saveStarted;

@property (retain, nonatomic) NSString *imageUrl;
@property (retain, nonatomic) NSString *imageName;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;

@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIProgressView *progressBar;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)showWindow;
- (void)createImageView;
- (void)hideWindow;
- (void)initializeConnection;
- (void)startRequest;
- (void)reloadProgressBar;
- (void)setImageAtImageView:(UIImage *)image;
- (void)saveImageForLibrary;

- (void)tapImageView:(UITapGestureRecognizer *)sender;
- (void)swipeUpImageView:(UISwipeGestureRecognizer *)sender;
- (void)longPressImageView:(UILongPressGestureRecognizer *)sender;
- (void)pinchImageView:(UIPinchGestureRecognizer *)sender;

@end

@implementation ImageWindow

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.2f
                                                 alpha:0.7f];
        [[self layer] setCornerRadius:10.0f];
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)loadImage:(NSString *)imageUrl viewRect:(CGRect)viewRect topMargin:(CGFloat)topMargin {
    
    if ( imageUrl == nil ||
        [imageUrl isEqualToString:@""] ) {
        
        [self hideWindow];
        
    } else {
        
        [self setSaveStarted:NO];
        [self setImageUrl:nil];
        
        NSString *fullSizeImageUrl = [FullSizeImage urlString:imageUrl];
        
        if ( ![fullSizeImageUrl isEqualToString:imageUrl] ) {
            
            //URLに変化がある場合(フルサイズURLになっている)は画像共有サービス
            [self setImageUrl:fullSizeImageUrl];
            [self setViewRect:[NSValue valueWithCGRect:viewRect]];
            [self showWindow];
            
        } else {
            
            if ( [FullSizeImage isSocialService:imageUrl] ) {
                
                //画像共有サービスだが開けない
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:imageUrl]];
                [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
                
            } else {
                
                NSMutableString *mString = [NSMutableString stringWithString:imageUrl];
                [mString replaceOccurrencesOfString:@"%2528" withString:@"(" options:0 range:NSMakeRange(0, mString.length)];
                [mString replaceOccurrencesOfString:@"%2529" withString:@")" options:0 range:NSMakeRange(0, mString.length)];
                
                //通常の画像
                [self setImageUrl:mString];
                [self setViewRect:[NSValue valueWithCGRect:viewRect]];
                [self setTopMargin:topMargin];
                [self showWindow];
            }
        }
    }
}

- (void)showWindow {
    
    CGRect viewRect = [self.viewRect CGRectValue];
    
    self.frame = CGRectMake(CGRectGetWidth(viewRect) / 2.0f - 2.0f,
                            (CGRectGetHeight(viewRect) / 2.0f - 2.0f) + self.topMargin,
                            2.0f,
                            2.0f);
    
    [UIView animateWithDuration:0.15
                     animations:^ {
                         
                         self.frame = CGRectMake(5.0f,
                                                 (CGRectGetHeight(viewRect) / 2.0f - 2.0f) + self.topMargin,
                                                 CGRectGetWidth(viewRect) - 10.0f,
                                                 2.0f);
                         
                     }completion:^ (BOOL completion) {
                         
                         [UIView animateWithDuration:0.25
                                          animations:^ {
                                              
                                              self.frame = CGRectMake(5.0f,
                                                                      CGRectGetMinY(viewRect) + 5.0f,
                                                                      CGRectGetWidth(viewRect) - 10.0f,
                                                                      CGRectGetHeight(viewRect) - 10.0f);
                                          }
                                          completion:^ (BOOL completion) {
                                              
                                              [self createImageView];
                                          }
                          ];
                     }
     ];
}

- (void)createImageView {
    
    self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5.0f,
                                                                    5.0f,
                                                                    CGRectGetWidth(self.frame) - 10.0f,
                                                                    CGRectGetHeight(self.frame) - 10.0f - PROGRESS_BAR_HEIGHT)] autorelease];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(move:)];
    [self.imageView addGestureRecognizer:pan];
    [pan release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapImageView:)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageView:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchImageView:)];
    [self.imageView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [self.imageView addSubview:self.activityIndicator];
    
    self.progressBar = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    self.progressBar.frame = CGRectMake(CGRectGetMinX(self.frame) + 10.0f,
                                        CGRectGetHeight(self.frame) - 5.0f - PROGRESS_BAR_HEIGHT,
                                        CGRectGetWidth(self.frame) - 30.0f,
                                        PROGRESS_BAR_HEIGHT);
    [self addSubview:self.progressBar];
    
    [self performSelector:@selector(initializeConnection) withObject:nil afterDelay:0.2];
}

- (void)tapImageView:(UITapGestureRecognizer *)sender {
    
    if ( self.imageView.image != nil ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:self.imageName
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"保存", @"保存して閉じる", @"アプリ内ブラウザで開く", @"Safariで開く", @"閉じる", nil];
        sheet.tag = 0;
        [sheet showInView:self];
        [sheet release];
        
    } else {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"閉じる", nil];
        sheet.tag = 1;
        [sheet showInView:self];
        [sheet release];
    }
}

- (void)swipeUpImageView:(UISwipeGestureRecognizer *)sender {
    
    [self hideWindow];
}

- (void)longPressImageView:(UILongPressGestureRecognizer *)sender {
    
    if ( self.imageView.image != nil &&
         !self.saveStarted ) {
        
        self.saveStarted = YES;
        self.afterClose = YES;
        
        [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
    }
}

- (void)pinchImageView:(UIPinchGestureRecognizer *)sender {
    
    if ( sender.state == UIGestureRecognizerStateBegan ) {
        
        _currentTransForm = self.imageView.transform;
    }
	
    CGFloat scale = [sender scale];
    [self setScale:scale];
    
    self.imageView.transform = CGAffineTransformConcat(_currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
    
    if ( actionSheet.tag == 0 ) {
        
        if ( buttonIndex == 0 ) {
            
            _afterClose = NO;
            
            [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
            
        } else if ( buttonIndex == 1 ) {
            
            _afterClose = YES;
            
            [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
            
        } else if ( buttonIndex == 2 ) {
            
            NSNotification *notification =[NSNotification notificationWithName:@"OpenTimelineURL"
                                                                        object:self
                                                                      userInfo:@{@"URL" : _imageUrl}];
            
            //通知を実行
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
            
        } else if ( buttonIndex == 3 ) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_imageUrl]];
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
            
        } else if ( buttonIndex == 4 ) {
            
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.2];
        }
        
    } else if ( actionSheet.tag == 1 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.2];
        }
    }
}

- (void)hideWindow {
    
    [self.connection cancel];
    [self setImageName:nil];
    [self setImageUrl:nil];
    [self setConnection:nil];
    [self setReceivedData:nil];
    
    CGRect rect = self.frame;
    
    [UIView animateWithDuration:0.25
                     animations:^ {
                         
                         self.frame = CGRectMake(5.0f,
                                                 (CGRectGetHeight(self.frame) / 2.0f + 2.0f) + self.topMargin,
                                                 CGRectGetWidth(self.frame),
                                                 2.0f);
                     }
                     completion:^ (BOOL completion) {
                         
                         [UIView animateWithDuration:0.15
                                          animations:^ {
                                              
                                              self.frame = CGRectMake(CGRectGetWidth(rect) / 2.0f + 2.0f,
                                                                      (CGRectGetHeight(rect) / 2.0f + 2.0f) + self.topMargin,
                                                                      2.0f,
                                                                      2.0f);
                                          }
                                          completion:^ (BOOL completion) {
                                              
                                              self.frame = CGRectZero;
                                              self.imageView.image = nil;
                                          }
                          ];
                     }
     ];
}

- (void)initializeConnection {
    
    [self setImageName:nil];
    
    [self setReceivedData:nil];
    self.receivedData = [[[NSMutableData alloc] initWithData:0] autorelease];
    
    [self setConnection:nil];
    
    //NSLog(@"LoadImage: %@", self.imageUrl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageUrl]];
    
    if ( [self.imageUrl rangeOfString:@"pixiv.net"].location != NSNotFound ) {
        
        [request setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                      delegate:self];
    
    [self startRequest];
}

- (void)startRequest {
    
    [self.progressBar setProgress:0];
    [self.connection start];
}

- (void)reloadProgressBar {
    
    [self.progressBar setProgress:(_receivedSize / _maxSize)];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"didReceiveResponse: %@", response.suggestedFilename);
    
    _imageName = response.suggestedFilename;
    [_imageName retain];
    
    _maxSize = [response expectedContentLength];
	_receivedSize = 0.0f;
    
    NSLog(@"FileSize: %.0f", _maxSize);
    
    [self.progressBar setProgress:_receivedSize];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //    NSLog(@"didReceiveData: %d", data.length);
    
    [self.receivedData appendData:data];
    
	_receivedSize += [data length];
    
    [self performSelectorOnMainThread:@selector(reloadProgressBar)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"connection didFailWithError");
    
    [self.connection cancel];
    [self hideWindow];
    
    [ShowAlert error:@"エラーが発生しました。"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"receiveData.length: %d, maxSize: %.0f", self.receivedData.length, _maxSize);
    
    if ( self.receivedData.length != 34 ) {
        
        UIImage *image = nil;
        if ( [self.imageUrl rangeOfString:@".gif"].location != NSNotFound ) {
            
            image = [UIImage animatedGIFWithData:self.receivedData];
            
        } else {
            
            image = [UIImage imageWithDataByContext:self.receivedData];
        }
        
        [self setImageAtImageView:image];
        
    } else {
        
        [ShowAlert error:@"未対応パターンのようです。"];
    }
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
    
    [ShowAlert title:@"保存完了" message:@"カメラロールに保存しました。"];
    
    _saveStarted = NO;
    
    [self.activityIndicator stopAnimating];
    
    if ( _afterClose ) {
        
        [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.2];
    }
}

- (void)setImageAtImageView:(UIImage *)image {
    
    self.imageView.image = image;
}

- (void)saveImageForLibrary {
    
    dispatch_async (dispatch_get_main_queue (), ^{
        
        self.activityIndicator.center = CGPointMake(self.imageView.frame.size.width / 2.0f,
                                                    self.imageView.frame.size.height / 2.0f);
        [self.activityIndicator startAnimating];
    });
    
    UIImageWriteToSavedPhotosAlbum(self.imageView.image,
                                   self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                   nil);
}

- (void)move:(UIPanGestureRecognizer *)sender {
    
    CGPoint p = [sender translationInView:self.imageView];
    CGFloat x = p.x * self.scale;
    CGFloat y = p.y * self.scale;
    
    CGPoint movedPoint = CGPointMake(self.imageView.center.x + x,
                                     self.imageView.center.y + y);
    self.imageView.center = movedPoint;
    [sender setTranslation:CGPointZero inView:self.imageView];
}

- (void)dealloc {
    
    [_imageName release];
    [_imageUrl release];
    [_connection release];
    [_receivedData release];
    [_imageView release];
    [_progressBar release];
    [_activityIndicator release];
    
    [super dealloc];
}

@end

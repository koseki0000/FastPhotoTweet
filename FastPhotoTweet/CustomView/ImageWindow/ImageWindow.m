//
//  ImageWindow.m
//

#import "ImageWindow.h"

#define SUPERVIEW_HEIGHT self.superview.frame.size.height
#define SUPERVIEW_WIDHT self.superview.frame.size.width
#define PROGRESS_BAR_HEIGHT 9

@implementation ImageWindow
@synthesize connection;
@synthesize receivedData;
@synthesize imageView;
@synthesize progressBar;
@synthesize activityIndicator;

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
        [[self layer] setCornerRadius:10.0];
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)loadImage:(NSString *)imageUrl viewRect:(CGRect)viewRect {
    
    if ( imageUrl == nil ||
        [imageUrl isEqualToString:@""] ) {
        
        [self hideWindow];
        
    }else {
        
        _saveStarted = NO;
        
        [self setImageUrl:nil];
        
        NSString *fullSizeImageUrl = [FullSizeImage urlString:imageUrl];
        
        if ( ![fullSizeImageUrl isEqualToString:imageUrl] ) {
         
            //URLに変化がある場合(フルサイズURLになっている)は画像共有サービス
            self.imageUrl = fullSizeImageUrl;
            [self.imageUrl retain];
            
            _viewRect = viewRect;
            
            [self showWindow];
            
        }else {
            
            if ( [FullSizeImage isSocialService:imageUrl] ) {
                
                //画像共有サービスだが開けない
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:imageUrl]];
                [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
                
            }else {
            
                NSMutableString *mString = [NSMutableString stringWithString:imageUrl];
                [mString replaceOccurrencesOfString:@"%2528" withString:@"(" options:0 range:NSMakeRange(0, mString.length)];
                [mString replaceOccurrencesOfString:@"%2529" withString:@")" options:0 range:NSMakeRange(0, mString.length)];
                
                //通常の画像
                self.imageUrl = mString;
                [self.imageUrl retain];
                
                _viewRect = viewRect;
                
                [self showWindow];
            }
        }
    }
}

- (void)showWindow {
    
    self.frame = CGRectMake(_viewRect.size.width / 2 - 2,
                            _viewRect.size.height / 2 - 2,
                            2,
                            2);
    
    [UIView animateWithDuration:0.2
                     animations:^ {
                         
                         self.frame = CGRectMake(5,
                                                 _viewRect.size.height / 2 - 2,
                                                 _viewRect.size.width - 10,
                                                 2);
                         
                     }completion:^ (BOOL completion) {
                         
                         [UIView animateWithDuration:0.3
                                          animations:^ {
                                              
                                              self.frame = CGRectMake(5,
                                                                      _viewRect.origin.y + 5,
                                                                      _viewRect.size.width - 10,
                                                                      _viewRect.size.height - 10);
                                          }
                                          completion:^ (BOOL completion) {
                                              
                                              [self createImageView];
                                          }
                          ];
                     }
     ];
}

- (void)createImageView {
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,
                                                              5,
                                                              self.frame.size.width - 10,
                                                              self.frame.size.height - 10 - PROGRESS_BAR_HEIGHT)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(swipeUpImageView:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [imageView addGestureRecognizer:swipeUpGesture];
    [swipeUpGesture release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapImageView:)];
    [imageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageView:)];
    longPressGesture.minimumPressDuration = 0.5;
    [imageView addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchImageView:)];
    [imageView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imageView addSubview:activityIndicator];
    
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressBar.frame = CGRectMake(self.frame.origin.x + 10,
                                   self.frame.size.height - 5 - PROGRESS_BAR_HEIGHT,
                                   self.frame.size.width - 30,
                                   PROGRESS_BAR_HEIGHT);
    [self addSubview:progressBar];
    
    [self performSelector:@selector(initializeConnection) withObject:nil afterDelay:0.2];
}

- (void)tapImageView:(UITapGestureRecognizer *)sender {
    
    if ( imageView.image != nil ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:self.imageName
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"保存", @"保存して閉じる", @"アプリ内ブラウザで開く", @"Safariで開く", @"閉じる", nil];
        sheet.tag = 0;
        [sheet showInView:self];
        [sheet release];
        
    }else {
        
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
    
    if ( imageView.image != nil && !_saveStarted ) {
     
        _saveStarted = YES;
        _afterClose = YES;
        
        [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
    }
}

- (void)pinchImageView:(UIPinchGestureRecognizer *)sender {
    
    if ( sender.state == UIGestureRecognizerStateBegan ) {
        
        currentTransForm = imageView.transform;
    }
	
    CGFloat scale = [sender scale];
    
    imageView.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
//    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
    
    if ( actionSheet.tag == 0 ) {
     
        if ( buttonIndex == 0 ) {
            
            _afterClose = NO;
            
            [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
            
        }else if ( buttonIndex == 1 ) {
            
            _afterClose = YES;
            
            [self performSelectorInBackground:@selector(saveImageForLibrary) withObject:nil];
            
        }else if ( buttonIndex == 2 ) {
            
            NSNotification *notification =[NSNotification notificationWithName:@"OpenTimelineURL"
                                                                        object:self
                                                                      userInfo:@{@"URL" : _imageUrl}];
            
            //通知を実行
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
            
        }else if ( buttonIndex == 3 ) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_imageUrl]];
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.1];
            
        }else if ( buttonIndex == 4 ) {
            
            [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.2];
        }
        
    }else if ( actionSheet.tag == 1 ) {
        
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
    
    [UIView animateWithDuration:0.3
                     animations:^ {
                         
                         self.frame = CGRectMake(5,
                                                 self.frame.size.height / 2 + 2,
                                                 self.frame.size.width,
                                                 2);
                         return;
                     }
                     completion:^ (BOOL completion) {
                         
                         [UIView animateWithDuration:0.2
                                          animations:^ {
                                              
                                              self.frame = CGRectMake(rect.size.width / 2 + 2,
                                                                      rect.size.height / 2 + 2,
                                                                      2,
                                                                      2);
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
    receivedData = [[NSMutableData alloc] initWithData:0];
    
    [self setConnection:nil];
    
    //NSLog(@"LoadImage: %@", self.imageUrl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageUrl]];
    
    if ( [self.imageUrl rangeOfString:@"pixiv.net"].location != NSNotFound ) {
        
        [request setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self];
    
    [self startRequest];
}

- (void)startRequest {
    
    [progressBar setProgress:0];
    [connection start];
}

- (void)reloadProgressBar {
    
    [progressBar setProgress:(_receivedSize / _maxSize)];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"didReceiveResponse: %@", response.suggestedFilename);
    
    _imageName = response.suggestedFilename;
    [_imageName retain];
    
    _maxSize = [response expectedContentLength];
	_receivedSize = 0.0;
    
    NSLog(@"FileSize: %.0f", _maxSize);
    
    [progressBar setProgress:_receivedSize];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
//    NSLog(@"didReceiveData: %d", data.length);
    
    [receivedData appendData:data];
    
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
    NSLog(@"receiveData.length: %d, maxSize: %.0f", receivedData.length, _maxSize);
    
    if ( receivedData.length != 34 ) {
     
        UIImage *image = [UIImage imageWithData:receivedData];
        
        [self setImageAtImageView:image];
        
    }else {
        
        [ShowAlert error:@"未対応パターンのようです。"];
    }
}

- (void) savingImageIsFinished:(UIImage *)image
      didFinishSavingWithError:(NSError *)error
                   contextInfo:(void *)contextInfo {
    
    [ShowAlert title:@"保存完了" message:@"カメラロールに保存しました。"];

    _saveStarted = NO;
    
    [activityIndicator stopAnimating];
    
    if ( _afterClose ) {
        
        [self performSelector:@selector(hideWindow) withObject:nil afterDelay:0.2];
    }
}

- (void)setImageAtImageView:(UIImage *)image {
    
    imageView.image = image;
}

- (void)saveImageForLibrary {
    
    dispatch_async (dispatch_get_main_queue (), ^{
        
        activityIndicator.center = CGPointMake(imageView.frame.size.width / 2,
                                               imageView.frame.size.height / 2);
        [activityIndicator startAnimating];
    });
    
    UIImageWriteToSavedPhotosAlbum(imageView.image,
                                   self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                   nil);
}

- (void)dealloc {
    
    [self setImageName:nil];
    [self setImageUrl:nil];
    [self setConnection:nil];
    [self setReceivedData:nil];
    [self setImageView:nil];
    [self setProgressBar:nil];
    [self setActivityIndicator:nil];
    
    [super dealloc];
}

@end

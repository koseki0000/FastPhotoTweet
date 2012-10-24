//
//  ImageWindow.h
//

#import <UIKit/UIView.h>
#import <QuartzCore/QuartzCore.h>
#import "ShowAlert.h"
#import "FullSizeImage.h"

@interface ImageWindow : UIView <NSURLConnectionDelegate, UIActionSheetDelegate> {
    
    CGRect _viewRect;
    CGFloat _maxSize;
    CGFloat _receivedSize;
    
    BOOL _afterClose;
    BOOL _saveStarted;
}

@property (retain, nonatomic) NSString *imageUrl;
@property (retain, nonatomic) NSString *imageName;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;

@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIProgressView *progressBar;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)loadImage:(NSString *)imageUrl viewRect:(CGRect)viewRect;

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

@end

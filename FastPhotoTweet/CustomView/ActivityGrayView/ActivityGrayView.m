//
//  GrayView.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//

#import "ActivityGrayView.h"

//スクリーンのサイズ
#define SCREEN_HEIGHT [UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].applicationFrame.size.width
//GrayViewのサイズ
#define VIEW_SIZE 120

@implementation ActivityGrayView

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        //アニメーション中以外は非表示
        self.hidden = YES;
        //親ビューは画面いっぱいに貼り付ける
        self.frame = CGRectMake(0,
                                0,
                                SCREEN_WIDTH,
                                SCREEN_HEIGHT);
        //背景色は透明
        self.backgroundColor = [UIColor clearColor];
        
        //GrayView本体
        _grayView = [[[UIView alloc] init] autorelease];
        _grayView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
        //角を丸める
        [[_grayView layer] setCornerRadius:10.0];
        [_grayView setClipsToBounds:YES];
        [self addSubview:_grayView];
        
        //処理中を表すインディケーターを表示
        _activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        //表示位置は画面中央
        _activityIndicator.center = CGPointMake(self.frame.size.width / 2,
                                                self.frame.size.height / 2);
        [self addSubview:_activityIndicator];
        
        //各種初期値を設定
        [self setDefault];
    }
    
    return self;
}

+ (ActivityGrayView *)grayView {
    
    //タスク名を指定せず初期化
    return [[ActivityGrayView alloc] init];
}

+ (ActivityGrayView *)grayViewWithTaskName:(NSString *)taskName {
    
    //タスク名を指定して初期化
    ActivityGrayView *grayView = [[ActivityGrayView alloc] init];
    [grayView addTaskName:taskName];
    
    return grayView;
}

- (void)setDefault {
    
    //GrayViewの位置を初期位置にする
    _grayView.frame = CGRectMake(0,
                                 (SCREEN_HEIGHT - SCREEN_WIDTH) / 2,
                                 SCREEN_WIDTH,
                                 SCREEN_WIDTH);
    //透過を無効にする
    _activityIndicator.alpha = 1.0;
    _grayView.alpha = 1.0;
}

- (void)addTaskName:(NSString *)taskName {
    
    //タスク名を設定する
    self.taskName = taskName;
}

- (void)start {
    
    //エラーチェック
    if ( _grayView == nil || _activityIndicator == nil ) {
     
        NSLog(@"GrayView nil[%d]", _startCount);
        return;
    }
    
    //startが呼ばれた回数を増やす
    _startCount++;
    
    if ( _startCount == 1 ) {
        
        NSLog(@"GrayView start[%d]", _startCount);
        
        //初めて呼ばれた場合
        
        //非表示を解除する
        self.hidden = NO;
        //インディケーターのアニメーションを開始
        [_activityIndicator startAnimating];
        
        //0.2s掛けてアニメーションする
        [UIView animateWithDuration:0.2
                         animations:^ {
                             
                             //GrayViewのサイズを変更
                             _grayView.frame = CGRectMake(SCREEN_WIDTH / 2 - VIEW_SIZE / 2,
                                                          SCREEN_HEIGHT / 2 - VIEW_SIZE / 2,
                                                          VIEW_SIZE,
                                                          VIEW_SIZE);
                         }
         
//                         completion:^ (BOOL finished) {
//                             
//                             //アニメーション完了時に実行される
//                             
//                             //for Debug
//                             [self performSelector:@selector(end) withObject:nil afterDelay:2.0];
//                         }
         ];
        
//    }else {
//        
//        //for Debug
//        [self performSelector:@selector(end) withObject:nil afterDelay:2.0];
        
    }else {
        
        NSLog(@"start else[%d]", _startCount);
    }
}

- (void)end {
    
    //エラーチェック
    if ( _grayView == nil || _activityIndicator == nil ) {
     
        NSLog(@"GrayView nil[%d]", _startCount);
        return;
    }
    
    //startが呼ばれた回数を減らす
    _startCount--;
    
    if ( _startCount == 0 ) {
    
        NSLog(@"GrayView end[%d]", _startCount);
        
        //startが呼ばれた回数が0以下になった場合
        
        //0.2s掛けてアニメーション
        [UIView animateWithDuration:0.2
                         animations:^ {
                             
                             //GrayViewを徐々に薄くする
                             _activityIndicator.alpha = 0.0;
                             _grayView.alpha = 0.0;
                         }
         
                         completion:^ (BOOL finished) {
                             
                             //アニメーション完了後に実行される
                             
                             //非表示にする
                             self.hidden = YES;
                             //インディケーターのアニメーションを止める
                             [_activityIndicator stopAnimating];
                             
                             //次回表示のために設定を初期化する
                             [self setDefault];
                             
                             //タスク名が設定されている場合はタスク名と共に処理完了の通知を行う
                             NSNotification *doneNotification = [NSNotification notificationWithName:@"GrayViewDone"
                                                                                              object:self
                                                                                            userInfo:@{ @"TaskName" : self.taskName == nil ? @"" : self.taskName }];
                             [[NSNotificationCenter defaultCenter] postNotification:doneNotification];
                         }
         ];
    }
    
    if ( _startCount < 0 ) _startCount = 0;
}

- (void)forceEnd {
    
    _startCount = 1;
    [self end];
}

- (void)dealloc {
    
    NSLog(@"GrayView dealloc");
    
    if ( _activityIndicator.isAnimating ) [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
    _activityIndicator = nil;
    [_grayView removeFromSuperview];
    _grayView = nil;
    
    [super dealloc];
}

@end

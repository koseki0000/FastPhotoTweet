//
//  StatusBarInfo.h
//

#import <UIKit/UIKit.h>

@interface StatusBarInfo : UIWindow

@property (retain, nonatomic) UILabel *textLabel;
@property (retain, nonatomic) NSMutableArray *tasks;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSNumber *showTime;
@property (retain, nonatomic) NSNumber *checkInterval;

- (id)initWithShowTime:(NSNumber *)showTime checkInterval:(NSNumber *)checkInterval;
- (void)setNotifications;
- (void)startTimer:(NSNotification *)notification;
- (void)stopTimer:(NSNotification *)notification;
- (void)startWaitTask:(NSNotification *)notification;
- (void)stopWaitTask:(NSNotification *)notification;
- (void)addTask:(NSNotification *)notification;
- (void)checkTask;
- (void)showTask:(NSString *)task;
- (void)hideTask;

@end

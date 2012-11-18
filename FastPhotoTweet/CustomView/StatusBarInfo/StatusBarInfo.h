//
//  StatusBarInfo.h
//

#import <UIKit/UIKit.h>

@interface StatusBarInfo : UIWindow

typedef enum {
    StatusBarInfoAnimationTypeTopInToFadeOut,
    StatusBarInfoAnimationTypeRightInLeftOut
}StatusBarInfoAnimationType;

@property (retain, nonatomic) UILabel *textLabel;
@property (retain, nonatomic) NSMutableArray *tasks;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSNumber *showTime;
@property (retain, nonatomic) NSNumber *animationDuration;
@property StatusBarInfoAnimationType animationType;
@property (retain, nonatomic) NSNumber *taskCheckInterval;

- (id)initWithShowTime:(NSNumber *)showTime
     taskCheckInterval:(NSNumber *)taskCheckInterval
     animationDuration:(NSNumber *)animationDuration
         animationType:(StatusBarInfoAnimationType)animationType
       backgroundColor:(UIColor *)backgroundColor
             textColor:(UIColor *)textColor;

- (void)setNotifications;
- (void)startTimer:(NSNotification *)notification;
- (void)stopTimer:(NSNotification *)notification;
- (void)startWaitTask:(NSNotification *)notification;
- (void)stopWaitTask:(NSNotification *)notification;
- (void)addTask:(NSNotification *)notification;
- (void)checkTask;
- (void)showTask:(NSString *)task;
- (void)hideTask;

+ (void)srartTimer;
+ (void)stopTimer;
+ (void)startWaitTask;
+ (void)stopWaitTask;
+ (void)addTask:(NSString *)task;

@end
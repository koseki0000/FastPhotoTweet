//
//  StatusBarInfo.m
//

#import "StatusBarInfo.h"
#import "NSNotificationCenter+EasyPost.h"

#define DISPATCH_AFTER(delay) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(),

#define START_STATUS_BAR_TIMER      @"StartStatusBarTimer"
#define STOP_STATUS_BAR_TIMER       @"StopStatusBarTimer"
#define START_WAIT_STATUS_BAR_TASK  @"StartWaitStatusBarTask"
#define STOP_WAIT_STATUS_BAR_TASK   @"StopWaitStatusBarTask"
#define ADD_STATUS_BAR_TASK         @"AddStatusBarTask"

#define SHOW_POSITION  CGRectMake(   0.0f,   0.0f, 320.0f, 20.0f)
#define HIDE_POSITION  CGRectMake(   0.0f, -20.0f, 320.0f, 20.0f)
#define RIGHT_POSITION CGRectMake( 320.0f,   0.0f, 320.0f, 20.0f)
#define LEFT_POSITION  CGRectMake(-320.0f,   0.0f, 320.0f, 20.0f)

@interface StatusBarInfo ()

@property (nonatomic) BOOL showing;

@end

@implementation StatusBarInfo

#pragma mark - Initialize

- (id)initWithShowTime:(NSNumber *)showTime
     taskCheckInterval:(NSNumber *)taskCheckInterval
     animationDuration:(NSNumber *)animationDuration
         animationType:(StatusBarInfoAnimationType)animationType
       backgroundColor:(UIColor *)backgroundColor
             textColor:(UIColor *)textColor {
    
    self = [super initWithFrame:HIDE_POSITION];
    
    if ( self ) {
        
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = backgroundColor;
        self.hidden = NO;
        self.alpha = 1.0f;
        
        _tasks = [[NSMutableArray alloc] init];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                               0.0f,
                                                               320.0f,
                                                               20.0f)];
        [self addSubview:_textLabel];
        _textLabel.backgroundColor = backgroundColor;
        _textLabel.textColor = textColor;
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
        _textLabel.textAlignment = UITextAlignmentCenter;
        
        _showTime = showTime;
        _taskCheckInterval = taskCheckInterval;
        _animationDuration = animationDuration;
        _animationType = animationType;
        
        [self setNotifications];
        [self startTimer:nil];
    }
    
    return self;
}

- (void)setNotifications {
    
    [NOTIFICATION addObserver:self
                     selector:@selector(addTask:)
                         name:ADD_STATUS_BAR_TASK
                       object:nil];
    
    [NOTIFICATION addObserver:self
                     selector:@selector(startWaitTask:)
                         name:START_WAIT_STATUS_BAR_TASK
                       object:nil];
    
    [NOTIFICATION addObserver:self
                     selector:@selector(stopWaitTask:)
                         name:STOP_WAIT_STATUS_BAR_TASK
                       object:nil];
    
    [NOTIFICATION addObserver:self
                     selector:@selector(startTimer:)
                         name:START_STATUS_BAR_TIMER
                       object:nil];
    
    [NOTIFICATION addObserver:self
                     selector:@selector(stopTimer:)
                         name:STOP_STATUS_BAR_TIMER
                       object:nil];
}

#pragma mark - NotificationMethod

- (void)startTimer:(NSNotification *)notification {
    
    NSLog(@"startTimer");
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:[_taskCheckInterval floatValue]
                                              target:self
                                            selector:@selector(checkTask)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];
}

- (void)stopTimer:(NSNotification *)notification {
    
    NSLog(@"stopTimer");
    
    if ( _timer != nil ) {
     
        [_timer invalidate];
    }
}

- (void)startWaitTask:(NSNotification *)notification {
    
    NSLog(@"startWaitTask");
    
    [NOTIFICATION addObserver:self
                     selector:@selector(startWaitTask:)
                         name:START_WAIT_STATUS_BAR_TASK
                       object:nil];
}

- (void)stopWaitTask:(NSNotification *)notification {
    
    NSLog(@"stopWaitTask");
    
    [NOTIFICATION removeObserver:self];
    
    [NOTIFICATION addObserver:self
                     selector:@selector(startWaitTask:)
                         name:START_WAIT_STATUS_BAR_TASK
                       object:nil];
    [self stopTimer:nil];
}

- (void)addTask:(NSNotification *)notification {
    
    NSLog(@"addTask: %@", notification.userInfo);
    
    if( [notification.userInfo objectForKey:@"Task"] != nil ) {
        
        NSString *newTask = [notification.userInfo objectForKey:@"Task"];
        [_tasks addObject:newTask];
    }
}

- (void)checkTask {
    
    if ( _tasks.count != 0 ) {
        
        if ( !self.showing ) {
         
            NSLog(@"Find Task");
            
            [self showTask:[_tasks objectAtIndex:0]];
            [_tasks removeObjectAtIndex:0];
        }
    }
}

- (void)showTask:(NSString *)task {
    
    NSLog(@"showTask: %@", task);
    
    [self setShowing:YES];
    [self stopTimer:nil];
    
    __block StatusBarInfo *weakSelf = self;
    
    if ( task != nil ) {
        
        _textLabel.text = task;
        self.alpha = 1.0f;
        
        switch ( _animationType ) {
                
            case StatusBarInfoAnimationTypeTopInToFadeOut:
                
                self.frame = HIDE_POSITION;
                
                [UIView animateWithDuration:[_animationDuration floatValue]
                                 animations:^{
                                     
                                     weakSelf.frame = SHOW_POSITION;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [weakSelf hideTask];
                                 }
                 ];
                
                break;
                
            case StatusBarInfoAnimationTypeRightInLeftOut:
                
                self.frame = RIGHT_POSITION;
                
                [UIView animateWithDuration:[_animationDuration floatValue]
                                 animations:^{
                                     
                                     weakSelf.frame = SHOW_POSITION;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [weakSelf hideTask];
                                 }
                 ];
                
                break;
                
            default:
                break;
        }
        
    } else {
        
        DISPATCH_AFTER(0.3) ^{
            
            [weakSelf startTimer:nil];
        });
    }
}

- (void)hideTask {
    
    NSLog(@"hideTask");
    
    __block StatusBarInfo *weakSelf = self;
    
    switch ( _animationType ) {
            
        case StatusBarInfoAnimationTypeTopInToFadeOut:
            
            [UIView animateWithDuration:[_animationDuration floatValue]
                                  delay:[_showTime floatValue]
                                options:0
                             animations:^{
                                 
                                 weakSelf.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 
                                 weakSelf.frame = HIDE_POSITION;
                                 weakSelf.alpha = 1.0f;
                                 
                                 DISPATCH_AFTER(0.1) ^{
                                     
                                     [weakSelf startTimer:nil];
                                     [weakSelf setShowing:NO];
                                 });
                             }
             ];
            
            break;
            
        case StatusBarInfoAnimationTypeRightInLeftOut:
            
            [UIView animateWithDuration:[_animationDuration floatValue]
                                  delay:[_showTime floatValue]
                                options:0
                             animations:^{
                                 
                                 weakSelf.frame = LEFT_POSITION;
                             }
                             completion:^(BOOL finished) {
                                 
                                 weakSelf.frame = HIDE_POSITION;
                                 
                                 DISPATCH_AFTER(0.1) ^{
                                     
                                     [weakSelf startTimer:nil];
                                     [weakSelf setShowing:NO];
                                 });
                             }
             ];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - ClassMethod

+ (void)srartTimer {
    
    [NSNotificationCenter postNotificationCenterForName:START_STATUS_BAR_TIMER];
}

+ (void)stopTimer {
    
    [NSNotificationCenter postNotificationCenterForName:STOP_STATUS_BAR_TIMER];
}

+ (void)startWaitTask {
    
    [NSNotificationCenter postNotificationCenterForName:START_WAIT_STATUS_BAR_TASK];
}

+ (void)stopWaitTask {
    
    [NSNotificationCenter postNotificationCenterForName:STOP_WAIT_STATUS_BAR_TASK];
}

+ (void)addTask:(NSString *)task {
    
    if ( task != nil ) {
        
        [NSNotificationCenter postNotificationCenterForName:ADD_STATUS_BAR_TASK
                                               withUserInfo:@{@"Task" : task}];
    }
}

@end

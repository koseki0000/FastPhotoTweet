//
//  StatusBarInfo.m
//

#import "StatusBarInfo.h"

#define DISPATCH_AFTER(x) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, x * NSEC_PER_SEC), dispatch_get_main_queue(),

@implementation StatusBarInfo

- (id)initWithShowTime:(NSNumber *)showTime checkInterval:(NSNumber *)checkInterval {
    
    self = [super initWithFrame:CGRectMake(0, -20, 320, 20)];
    
    if ( self ) {
        
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor blackColor];
        self.hidden = NO;
        self.alpha = 1.0;
        
        _tasks = [[NSMutableArray alloc] init];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        [self addSubview:_textLabel];
        _textLabel.backgroundColor = [UIColor blackColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = UITextAlignmentCenter;
        
        _showTime = showTime;
        [_showTime retain];
        
        _checkInterval = checkInterval;
        [_checkInterval retain];
        
        [self setNotifications];
        [self startTimer:nil];
        [self startWaitTask:nil];
    }
    
    return self;
}

- (void)setNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startWaitTask:)
                                                 name:@"StartWaitStatusBarTask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopWaitTask:)
                                                 name:@"StopWaitStatusBarTask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startTimer:)
                                                 name:@"StartStatusBarTimer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopTimer:)
                                                 name:@"StopStatusBarTimer"
                                               object:nil];
}

- (void)startTimer:(NSNotification *)notification {
    
    [self stopTimer:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:[_checkInterval floatValue]
                                              target:self
                                            selector:@selector(checkTask)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];
}

- (void)stopTimer:(NSNotification *)notification {
    
    if ( _timer.isValid ) [_timer invalidate];
    if ( _timer != nil ) _timer = nil;
}

- (void)startWaitTask:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addTask:)
                                                 name:@"AddStatusBarTask"
                                               object:nil];
}

- (void)stopWaitTask:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTask:(NSNotification *)notification {
    
    //NSLog(@"addTask: %@", notification.userInfo);
    
    if( [notification.userInfo objectForKey:@"Task"] != nil ) {
        
        NSString *newTask = [notification.userInfo objectForKey:@"Task"];
        [_tasks addObject:newTask];
    }
}

- (void)checkTask {
    
    if ( _tasks.count != 0 ) {
        
        [self showTask:[_tasks objectAtIndex:0]];
        [_tasks removeObjectAtIndex:0];
    }
}

- (void)showTask:(NSString *)task {
    
    NSLog(@"showTask: %@", task);
    
    [self stopTimer:nil];
    
    if ( task != nil ) {
    
        _textLabel.text = task;
        self.frame = CGRectMake(0, -20, 320, 20);
        self.alpha = 1.0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             self.frame = CGRectMake(0, 0, 320, 20);
                         }
                         completion:^(BOOL completion) {
                          
                             DISPATCH_AFTER([_showTime floatValue]) ^{
                                 
                                 [self hideTask];
                             });
                         }
         ];
        
    }else {
        
        DISPATCH_AFTER(0.3) ^{
            
            [self startTimer:nil];
        });
    }
}

- (void)hideTask {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL completion) {
                         
                         self.frame = CGRectMake(0, -20, 320, 20);
                         self.alpha = 1.0;
                         
                         DISPATCH_AFTER(0.1) ^{
                             
                             [self startTimer:nil];
                         });
                     }
     ];
}

- (void)dealloc {
    
    [_textLabel release];
    [_tasks release];
    [self stopTimer:nil];
    [_showTime release];
    [_checkInterval release];
    
    [super dealloc];
}

@end

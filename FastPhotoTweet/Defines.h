//
//  Defines.h
//
//  Created by @peace3884 on 2013/03/10.
//  Copyright (c) 2013年 @peace3884. All rights reserved.
//

typedef enum {
    TimelineCellTypeMain,
    TimelineCellTypeMenu
} TimelineCellType;

#define SCREEN_HEIGHT [UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].applicationFrame.size.width
#define MAIN_MARGIN 4.0f
#define MINI_MARGIN 2.0f
#define SEGMENT_BAR_HEIGHT 30.0f
#define PROGRESS_BAR_HEIGHT 9.0f
#define PICKER_HEIGHT 216.0f
#define STATUS_BAR_HEIGHT 20.0f
#define TAB_BAR_HEIGHT 48.0f
#define TOOL_BAR_HEIGHT 44.0f
#define IPHONE_IAD_HEIGHT_PORTRAIT 50.0f
#define IPHONE_IAD_HEIGHT_LANDSCAPE 32.0f
#define IPAD_IAD_HEIGHT_PORTRAIT 66.0f
#define IPAD_IAD_HEIGHT_LANDSCAPE 66.0f

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define P_BOARD [UIPasteboard generalPasteboard]
#define ORIENTATION [[UIDevice currentDevice] orientation]
#define FIRMWARE_VERSION [[UIDevice currentDevice] systemVersion]

#define MAIN_QUEUE dispatch_get_main_queue()
#define ASYNC_MAIN_QUEUE dispatch_async(dispatch_get_main_queue(),
#define SYNC_MAIN_QUEUE dispatch_sync(dispatch_get_main_queue(),
#define GLOBAL_QUEUE_DEFAULT dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 )
#define GLOBAL_QUEUE_HIGH dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 )
#define GLOBAL_QUEUE_BACKGROUND dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 )

#define DISPATCH_AFTER(delay) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), MAIN_QUEUE,

#define LOGS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Logs"]

#define OCEAN_COLOR [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0]

#define IMGUR_API_KEY   @"6de089e68b55d6e390d246c4bf932901"
#define TWITPIC_API_KEY @"95cf146048caad3267f95219b379e61c"
#define OAUTH_KEY       @"dVbmOIma7UCc5ZkV3SckQ"
#define OAUTH_SECRET    @"wnDptUj4VpGLZebfLT3IInTZPkPS4XimYh6WXAmdI"

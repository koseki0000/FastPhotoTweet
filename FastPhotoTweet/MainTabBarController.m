//
//  MainTabBarController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/22.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"

@implementation MainTabBarController

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        hiddenTabBar = NO;
        orientation = NO;
    }
    
    return self;
}

- (void)setBarHidden:(BOOL)hidden {
    
    hiddenTabBar = hidden;
    
    for ( UIView *view in self.view.subviews ) {
        
		if ( [view isKindOfClass:[UITabBar class]] ) {
            
            CGRect _rect = view.frame;
            
            if ( !hidden ) {
                
				_rect.origin.y = SCREEN_HEIGHT + STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT;
				[view setFrame:_rect];
                
			} else {
                
				_rect.origin.y = SCREEN_HEIGHT + STATUS_BAR_HEIGHT;
				[view setFrame:_rect];
			}
		}
	}
    
    [self endHidden];
}

- (void)endHidden {
    
	for ( UIView *view in self.view.subviews ) {
        
		if ( ![view isKindOfClass:[UITabBar class]] ) {
            
            CGRect _rect = view.frame;
            
			if ( !hiddenTabBar ) {
                
				_rect.origin.y = 0;
				_rect.size.height = SCREEN_HEIGHT + STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT;;
				[view setFrame:_rect];
                
			}else {
                
				_rect.size.height = SCREEN_HEIGHT + STATUS_BAR_HEIGHT;
				[view setFrame:_rect];
			}
		}
	}
}

- (void)enableOrientation {
    
    //NSLog(@"enableOrientation");
    orientation = YES;
}
- (void)disableOrientation {
    
    //NSLog(@"disableOrientation");
    orientation = NO;
}

- (BOOL)shouldAutorotate {
    
    //NSLog(@"shouldAutorotate: %d", orientation);
    return orientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

//    if ( interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
//     
//        NSLog(@"MainTabBarController AutorotateUpsideDown");
//        return NO;
//    }
    
//    if ( self.selectedIndex == 0 || self.selectedIndex == 1 ) {
//        
//        NSLog(@"MainTabBarController Autorotate index0, 1");
//        return NO;
//        
//    }else {
    
//        NSLog(@"MainTabBarController AutorotatePortrait or Landscape: %d", interfaceOrientation);
    
        NSNotification *notification =[NSNotification notificationWithName:@"Orientation"
                                                                    object:self
                                                                  userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return YES;
//    }
    
//    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    NSLog(@"supportedInterfaceOrientations");
    
    NSNotification *notification =[NSNotification notificationWithName:@"Orientation"
                                                                object:self
                                                              userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end

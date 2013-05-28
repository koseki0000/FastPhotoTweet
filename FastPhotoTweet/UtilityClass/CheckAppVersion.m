//
//  CheckAppVersion.m
//  FastPhotoTweet
//

#import "CheckAppVersion.h"
#import "NSObject+EmptyCheck.h"

@interface CheckAppVersion ()

@property (nonatomic, copy) NSString *updateIpaURL;

@end

@implementation CheckAppVersion

- (oneway void)versionInfoURL:(NSString *)versionInfoURL updateIpaURL:(NSString *)updateIpaURL {
    
    if ( [versionInfoURL isEmpty] ||
         [updateIpaURL isEmpty] ) {
        
        return;
    }
    
    [self setUpdateIpaURL:updateIpaURL];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
//    NSString *currentAppVersion = info[@"CFBundleShortVersionString"];
    NSString *currentBuildVersion = info[@"CFBundleVersion"];
    NSLog(@"currentBuildVersion: %@", currentBuildVersion);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
       
        NSError *error = nil;
        NSURL *URL = [NSURL URLWithString:versionInfoURL];
        NSString *latestVersionInfo = [[NSString alloc] initWithContentsOfURL:URL
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:&error];
        NSLog(@"%@", latestVersionInfo);
        
        if ( !error &&
             [latestVersionInfo isNotEmpty] ) {
            
            NSArray *splitedLatestVersionInfo = [latestVersionInfo componentsSeparatedByString:@"\n"];
            NSLog(@"splitedLatestVersionInfo: %@", splitedLatestVersionInfo);
            
            if ( [splitedLatestVersionInfo count] == 2 ) {
                
//                NSString *latestAppVersion = splitedLatestVersionInfo[0];
                NSString *latestBuildVersion = splitedLatestVersionInfo[1];
                NSLog(@"latestBuildVersion: %@", latestBuildVersion);
                
                //ビルド番号を先にチェック
                NSInteger currentBuildVersionNumber = [currentBuildVersion integerValue];
                NSInteger latestBuildVersionNumber = [latestBuildVersion integerValue];
                if ( currentBuildVersionNumber < latestBuildVersionNumber ) {
                    
                    //更新の必要がある
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新しいバージョンがあります"
                                                                        message:@"今すぐ更新を行いますか？"
                                                                       delegate:self
                                                              cancelButtonTitle:@"後で行う"
                                                              otherButtonTitles:@"更新", nil];
                        [alert show];
                    });
                }
                
                //ビルド番号のチェックだけでいい…？
            }
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex != alertView.cancelButtonIndex ) {
        
        NSURL *updateIpaURL = [NSURL URLWithString:self.updateIpaURL];
        [[UIApplication sharedApplication] openURL:updateIpaURL];
    }
}

@end

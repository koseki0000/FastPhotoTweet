//
//  TWIconResizer.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>

typedef enum {
    IconSizeMini,
    IconSizeNormal,
    IconSizeBigger,
    IconSizeOriginal,
    IconSizeOriginal96
}IconSize;

@interface TWIconResizer : NSObject

+ (NSString *)iconURL:(NSString *)iconURL iconSize:(IconSize)iconSize;

@end

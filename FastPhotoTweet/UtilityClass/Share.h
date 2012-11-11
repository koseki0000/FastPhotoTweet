//
//  Share.h
//

#import "ShareBase.h"

@interface Share : ShareBase

+ (Share *)manager;

#pragma mark - UIImage

+ (NSMutableDictionary *)images;

+ (void)cacheImageWithName:(NSString *)imageName doneNotification:(BOOL)notification;
+ (void)cacheImageWithName:(NSString *)imageName targetClass:(Class)targetClass doneNotification:(BOOL)notification;
+ (void)cacheImageWithNames:(NSArray *)imageNames doneNotification:(BOOL)notification;
+ (void)cacheImageWithNames:(NSArray *)imageNames targetClass:(Class)targetClass doneNotification:(BOOL)notification;

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath doneNotification:(BOOL)notification;
+ (void)cacheImageWithContentsOfFile:(NSString *)filePath targetClass:(Class)targetClass doneNotification:(BOOL)notification;
+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths doneNotification:(BOOL)notification;
+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths targetClass:(Class)targetClass doneNotification:(BOOL)notification;

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName doneNotification:(BOOL)notification;
+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName targetClass:(Class)targetClass doneNotification:(BOOL)notification;
+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames doneNotification:(BOOL)notification;
+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames targetClass:(Class)targetClass doneNotification:(BOOL)notification;

+ (void)removeImage:(NSString *)imageName;
+ (void)removeImage:(NSString *)imageName targetClass:(Class)targetClass;

+ (void)removeAllImageForClass:(Class)targetClass;
+ (void)removeAllImages;

#pragma mark -

+ (void)addClassDirectory:(Class)targetClass;
+ (void)imageCachedNotification:(NSString *)cachedImageName classNameOrNil:(NSString *)className;

@end

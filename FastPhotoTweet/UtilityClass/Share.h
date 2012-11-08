//
//  Share.h
//

#import "ShareBase.h"

@interface Share : ShareBase

+ (Share *)manager;

#pragma mark - UIImage

+ (NSMutableDictionary *)images;

+ (void)cacheImageWithName:(NSString *)imageName;
+ (void)cacheImageWithName:(NSString *)imageName targetClass:(Class)targetClass;
+ (void)cacheImageWithNames:(NSArray *)imageNames;
+ (void)cacheImageWithNames:(NSArray *)imageNames targetClass:(Class)targetClass;

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath;
+ (void)cacheImageWithContentsOfFile:(NSString *)filePath targetClass:(Class)targetClass;
+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths;
+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths targetClass:(Class)targetClass;

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName;
+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName targetClass:(Class)targetClass;
+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames;
+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames targetClass:(Class)targetClass;

+ (void)removeImage:(NSString *)imageName;
+ (void)removeImage:(NSString *)imageName targetClass:(Class)targetClass;

+ (void)removeAllImageForClass:(Class)targetClass;
+ (void)removeAllImages;

#pragma mark -

+ (void)addClassDirectory:(Class)targetClass;
+ (void)imageCachedNotification:(NSString *)cachedImageName classNameOrNil:(NSString *)className;

@end

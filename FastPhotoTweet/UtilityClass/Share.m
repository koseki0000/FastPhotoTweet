//
//  Share.m
//

#import "Share.h"
#import "NSObject+EmptyCheck.h"
#import "UIImage+Convert.h"

@implementation Share

+ (Share *)manager {
    
    return (Share *)[ShareBase manager];
}

#pragma mark - UIImage

+ (NSMutableDictionary *)images {
    
    return [ShareBase images];
}

+ (void)cacheImageWithName:(NSString *)imageName doneNotification:(BOOL)notification {
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    if ( image != nil && [[Share images] objectForKey:imageName] == nil ) {
        
        NSLog(@"cacheImageWithName: %@", imageName);
        [[Share images] setObject:image forKey:imageName];
        if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:nil];
    }
}

+ (void)cacheImageWithName:(NSString *)imageName targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    [Share addClassDirectory:targetClass];
    
    UIImage *image = [UIImage imageNamed:imageName];
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( image != nil && [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
        
        NSLog(@"cacheImageWithName(%@): %@", targetClass, imageName);
        [[[Share images] objectForKey:className] setObject:image forKey:imageName];
        if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:className];
    }
    
    [className release];
}

+ (void)cacheImageWithNames:(NSArray *)imageNames doneNotification:(BOOL)notification {
    
    for ( NSString *imageName in imageNames ) {
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        if ( image != nil && [[Share images] objectForKey:imageName] == nil ) {
            
            [[Share images] setObject:image forKey:imageName];
            if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:nil];
        }
    }
}

+ (void)cacheImageWithNames:(NSArray *)imageNames targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    [Share addClassDirectory:targetClass];
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    for ( NSString *imageName in imageNames ) {
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        if ( image != nil && [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
            
            NSLog(@"cacheImageWithNames(%@): %@", targetClass, imageName);
            [[[Share images] objectForKey:className] setObject:image forKey:imageName];
            if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:className];
        }
    }
    
    [className release];
}

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath doneNotification:(BOOL)notification {
    
    UIImage *image = [UIImage imageWithContentsOfFileByContext:filePath];
    NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
    
    if ( image != nil && [[Share images] objectForKey:fileName] == nil ) {
        
        [[Share images] setObject:image forKey:fileName];
        if ( notification ) [Share imageCachedNotification:fileName classNameOrNil:nil];
    }
    
    [fileName release];
}

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    [Share addClassDirectory:targetClass];
    
    UIImage *image = [UIImage imageWithContentsOfFileByContext:filePath];
    NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( image != nil && [[[Share images] objectForKey:className] objectForKey:fileName] == nil ) {
        
        NSLog(@"cacheImageWithContentsOfFile(%@): %@", targetClass, fileName);
        [[[Share images] objectForKey:className] setObject:image forKey:fileName];
        if ( notification ) [Share imageCachedNotification:fileName classNameOrNil:className];
    }
    
    [fileName release];
    [className release];
}

+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths doneNotification:(BOOL)notification {
    
    for ( NSString *filePath in filePaths ) {
        
        UIImage *image = [UIImage imageWithContentsOfFileByContext:filePath];
        NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
        
        if ( image != nil && [[Share images] objectForKey:fileName] == nil ) {
            
            [[Share images] setObject:image forKey:fileName];
            if ( notification ) [Share imageCachedNotification:fileName classNameOrNil:nil];
        }
        
        [fileName release];
    }
}

+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    [Share addClassDirectory:targetClass];
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    for ( NSString *filePath in filePaths ) {
        
        UIImage *image = [UIImage imageWithContentsOfFileByContext:filePath];
        NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
        
        if ( image != nil && [[[Share images] objectForKey:className] objectForKey:fileName] == nil ) {
            
            NSLog(@"cacheImageWithContentsOfFiles(%@): %@", targetClass, fileName);
            [[[Share images] objectForKey:className] setObject:image forKey:fileName];
            if ( notification ) [Share imageCachedNotification:fileName classNameOrNil:className];
        }
        
        [fileName release];
    }
    
    [className release];
}

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName doneNotification:(BOOL)notification {
    
    if ( [[Share images] objectForKey:imageName] == nil ) {
        
        [[Share images] setObject:image forKey:imageName];
        if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:nil];
    }
}

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    [Share addClassDirectory:targetClass];
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
        
        NSLog(@"cacheImage(%@): %@", targetClass, imageName);
        [[[Share images] objectForKey:className] setObject:image forKey:imageName];
        if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:className];
    }
    
    [className release];
}

+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames doneNotification:(BOOL)notification {
    
    NSUInteger index = 0;
    for ( NSString *imageName in imageNames ) {
        
        if ( [[Share images] objectForKey:imageName] == nil ) {
            
            [[Share images] setObject:[images objectAtIndex:index] forKey:imageName];
            if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:nil];
        }
        
        index++;
    }
}

+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames targetClass:(Class)targetClass doneNotification:(BOOL)notification {
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    NSUInteger index = 0;
    for ( NSString *imageName in imageNames ) {
        
        if ( [[Share images] objectForKey:imageName] == nil ) {
            
            NSLog(@"cacheImages(%@): %@", targetClass, imageName);
            [[[Share images] objectForKey:className] setObject:[images objectAtIndex:index] forKey:imageName];
            if ( notification ) [Share imageCachedNotification:imageName classNameOrNil:className];
        }
        
        index++;
    }
    
    [className release];
}

+ (void)removeImage:(NSString *)imageName {
    
    if ( [[Share images] objectForKey:imageName] != nil ) {
        
        NSLog(@"removeImage: %@", imageName);
        [[Share images] removeObjectForKey:imageName];
    }
}

+ (void)removeImage:(NSString *)imageName targetClass:(Class)targetClass {
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( [[Share images] objectForKey:className] != nil ) {
        
        NSLog(@"removeImage(%@): %@", targetClass, imageName);
        [[[Share images] objectForKey:className] removeObjectForKey:imageName];
    }
    
    [className release];
}

+ (void)removeAllImageForClass:(Class)targetClass {
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( [[Share images] objectForKey:className] != nil ) {
        
        NSLog(@"removeAllImageForClass(%@)", targetClass);
        [[Share images] removeObjectForKey:className];
    }
    
    [className release];
}

+ (void)removeAllImages {
    
    NSLog(@"RemoveAllImageCache");
    [[Share images] removeAllObjects];
}

#pragma mark -

+ (void)addClassDirectory:(Class)targetClass {
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( [[Share images] objectForKey:className] == nil ) {
        
        NSLog(@"addClassDirectory: %@", className);
        [[Share images] setObject:[NSMutableDictionary dictionary] forKey:className];
    }
    
    [className release];
}

+ (void)imageCachedNotification:(NSString *)cachedImageName classNameOrNil:(NSString *)className {
    
    if ( [cachedImageName isNotEmpty] ) {
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:cachedImageName forKey:@"CachedImageName"];
        
        if ( className != nil ) {
            
            [userInfo setObject:className forKey:@"CachedClassName"];
        }
        
        NSNotification *doneNotification = [NSNotification notificationWithName:@"ImageCached"
                                                                         object:self
                                                                       userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:doneNotification];
    }
}

@end

//
//  Share.m
//

#import "Share.h"
#import "NSObject+EmptyCheck.h"

@implementation Share

+ (Share *)manager {
    
    return (Share *)[ShareBase manager];
}

#pragma mark - UIImage

+ (NSMutableDictionary *)images {
    
    return [ShareBase images];
}

+ (void)cacheImageWithName:(NSString *)imageName {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        if ( image != nil && [[Share images] objectForKey:imageName] == nil ) {
            
            NSLog(@"cacheImageWithName: %@", imageName);
            [[Share images] setObject:image forKey:imageName];
            [Share imageCachedNotification:imageName classNameOrNil:nil];
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithName:(NSString *)imageName targetClass:(Class)targetClass {
    
    [Share addClassDirectory:targetClass];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *image = [UIImage imageNamed:imageName];
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        if ( image != nil && [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
            
            NSLog(@"cacheImageWithName(%@): %@", targetClass, imageName);
            [[[Share images] objectForKey:className] setObject:image forKey:imageName];
            [Share imageCachedNotification:imageName classNameOrNil:className];
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithNames:(NSArray *)imageNames {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        for ( NSString *imageName in imageNames ) {
            
            UIImage *image = [UIImage imageNamed:imageName];
            
            if ( image != nil && [[Share images] objectForKey:imageName] == nil ) {
                
                [[Share images] setObject:image forKey:imageName];
                [Share imageCachedNotification:imageName classNameOrNil:nil];
            }
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithNames:(NSArray *)imageNames targetClass:(Class)targetClass {
    
    [Share addClassDirectory:targetClass];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        for ( NSString *imageName in imageNames ) {
            
            UIImage *image = [UIImage imageNamed:imageName];
            
            if ( image != nil && [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
                
                NSLog(@"cacheImageWithNames(%@): %@", targetClass, imageName);
                [[[Share images] objectForKey:className] setObject:image forKey:imageName];
                [Share imageCachedNotification:imageName classNameOrNil:className];
            }
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
        
        if ( image != nil && [[Share images] objectForKey:fileName] == nil ) {
            
            [[Share images] setObject:image forKey:fileName];
            [Share imageCachedNotification:fileName classNameOrNil:nil];
        }
        
        [image release];
        [fileName release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithContentsOfFile:(NSString *)filePath targetClass:(Class)targetClass {
    
    [Share addClassDirectory:targetClass];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        if ( image != nil && [[[Share images] objectForKey:className] objectForKey:fileName] == nil ) {
            
            NSLog(@"cacheImageWithContentsOfFile(%@): %@", targetClass, fileName);
            [[[Share images] objectForKey:className] setObject:image forKey:fileName];
            [Share imageCachedNotification:fileName classNameOrNil:className];
        }
        
        [image release];
        [fileName release];
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths {
 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        for ( NSString *filePath in filePaths ) {
         
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
            NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
            
            if ( image != nil && [[Share images] objectForKey:fileName] == nil ) {
                
                [[Share images] setObject:image forKey:fileName];
                [Share imageCachedNotification:fileName classNameOrNil:nil];
            }
            
            [image release];
            [fileName release];
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImageWithContentsOfFiles:(NSArray *)filePaths targetClass:(Class)targetClass {
    
    [Share addClassDirectory:targetClass];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        for ( NSString *filePath in filePaths ) {
         
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
            NSString *fileName = [[NSString alloc] initWithString:[filePath lastPathComponent]];
            
            if ( image != nil && [[[Share images] objectForKey:className] objectForKey:fileName] == nil ) {
                
                NSLog(@"cacheImageWithContentsOfFiles(%@): %@", targetClass, fileName);
                [[[Share images] objectForKey:className] setObject:image forKey:fileName];
                [Share imageCachedNotification:fileName classNameOrNil:className];
            }
            
            [image release];
            [fileName release];
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if ( [[Share images] objectForKey:imageName] == nil ) {
            
            [[Share images] setObject:image forKey:imageName];
            [Share imageCachedNotification:imageName classNameOrNil:nil];
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImage:(UIImage *)image forName:(NSString *)imageName targetClass:(Class)targetClass {
    
    [Share addClassDirectory:targetClass];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        if ( [[[Share images] objectForKey:className] objectForKey:imageName] == nil ) {
            
            NSLog(@"cacheImage(%@): %@", targetClass, imageName);
            [[[Share images] objectForKey:className] setObject:image forKey:imageName];
            [Share imageCachedNotification:imageName classNameOrNil:className];
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSUInteger index = 0;
        for ( NSString *imageName in imageNames ) {
            
            if ( [[Share images] objectForKey:imageName] == nil ) {
                
                [[Share images] setObject:[images objectAtIndex:index] forKey:imageName];
                [Share imageCachedNotification:imageName classNameOrNil:nil];
            }
            
            index++;
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)cacheImages:(NSArray *)images forName:(NSArray *)imageNames targetClass:(Class)targetClass {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        NSUInteger index = 0;
        for ( NSString *imageName in imageNames ) {
            
            if ( [[Share images] objectForKey:imageName] == nil ) {
                
                NSLog(@"cacheImages(%@): %@", targetClass, imageName);
                [[[Share images] objectForKey:className] setObject:[images objectAtIndex:index] forKey:imageName];
                [Share imageCachedNotification:imageName classNameOrNil:className];
            }
            
            index++;
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)removeImage:(NSString *)imageName {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
        if ( [[Share images] objectForKey:imageName] != nil ) {
            
            NSLog(@"removeImage: %@", imageName);
            [[Share images] removeObjectForKey:imageName];
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)removeImage:(NSString *)imageName targetClass:(Class)targetClass {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        if ( [[Share images] objectForKey:className] != nil ) {
            
            NSLog(@"removeImage(%@): %@", targetClass, imageName);
            [[[Share images] objectForKey:className] removeObjectForKey:imageName];
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)removeAllImageForClass:(Class)targetClass {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
        NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
        
        if ( [[Share images] objectForKey:className] != nil ) {
            
            NSLog(@"removeAllImageForClass(%@)", targetClass);
            [[Share images] removeObjectForKey:className];
        }
        
        [className release];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)removeAllImages {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
        NSLog(@"RemoveAllImageCache");
        [[Share images] removeAllObjects];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

#pragma mark -

+ (void)addClassDirectory:(Class)targetClass {
    
    NSString *className = [[NSString alloc] initWithString:NSStringFromClass(targetClass)];
    
    if ( [[Share images] objectForKey:className] == nil ) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            NSLog(@"addClassDirectory: %@", className);
            [[Share images] setObject:[NSMutableDictionary dictionary] forKey:className];
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
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

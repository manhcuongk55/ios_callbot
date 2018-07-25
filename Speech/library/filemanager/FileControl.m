//
//  FileControl.m
//  sources
//
//  Created by Phu on 1/23/17.
//
//

#import "FileControl.h"

@interface FileControl () {
}
@end

@implementation FileControl

static FileControl *inst = nil;

+ (FileControl*) instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}

- (instancetype) init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (void) checkCreateFolder: (NSString *) folderName {
    NSString *folderPath = [self genDirForFileInDocumentDir:folderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
- (BOOL) checkFileInMainBundle:(NSString *)fileName withExtension:(NSString *)extension {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    if (data != nil) {
        //NSLog(@"★★★★★ FileControl: checkFileInMainBundle: Existed database.db %@", [self getCurrentDocumentDataApp]);
    }
    else {
        //NSLog(@"★★★★★ FileControl: checkFileInMainBundle: Not Existed database.db");
    }
    return data != nil;
}

- (NSString *) getCurrentDocumentDataApp {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *) genDirForFileInDocumentDir:(NSString *)fileName {
    NSString *dir = [self getCurrentDocumentDataApp];
    dir = [dir stringByAppendingPathComponent:fileName];
    return dir;
}

- (void) copyFileInMainBundle:(NSString *)fileName toDir:(NSString *)dir {
    NSFileManager *fmngr = [NSFileManager defaultManager];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError *error;
    if(![fmngr copyItemAtPath:filePath toPath:dir error:&error]) {
        
        //NSLog(@"★★★★★ FileControl: copyFileInMainBundle: Error copying item to dir %@", [error description]);
        
    }
    else {
        //NSLog(@"★★★★★ FileControl: copyFileInMainBundle: Success copy item to dir %@", [error description]);
    }
}

- (void) deleteFile: (NSString *) filePath {
    
    NSFileManager *fmngr = [NSFileManager defaultManager];
    
    if (![fmngr fileExistsAtPath:filePath]) {
    }
    else {
        [fmngr removeItemAtPath:filePath error:nil];
    }
    //NSLog(@"ket qua delete %d", [self checkFileExist:filePath]?0:1);
}
- (BOOL) checkFileExist: (NSString *) filePath {
    NSFileManager *fmngr = [NSFileManager defaultManager];
    
    return [fmngr fileExistsAtPath:filePath];
}
- (void) writeDataToFile: (NSData*) data toFile: (NSString *) filePath {
    [self deleteFile:filePath];
    [data writeToFile:filePath atomically:NO];
}
- (NSData *) getDataFromFilePath: (NSString *) filePath {
    return [NSData dataWithContentsOfFile:filePath];
}
- (long long) getFileSize:(NSString *)filePath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: filePath error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    return fileSize;
}
@end

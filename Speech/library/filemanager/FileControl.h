//
//  FileControl.h
//  sources
//
//  Created by Phu on 1/23/17.
//
//

#import <Foundation/Foundation.h>

@interface FileControl : NSObject

+ (FileControl*)instance;

- (BOOL) checkFileInMainBundle: (NSString *) fileName withExtension: (NSString *) extension;

- (NSString *) getCurrentDocumentDataApp;

- (NSString *) genDirForFileInDocumentDir: (NSString *) fileName;

- (void) copyFileInMainBundle: (NSString *) filePath toDir: (NSString *) dir;

- (void) deleteFile: (NSString *) filePath;

- (BOOL) checkFileExist: (NSString *) filePath;

- (void) checkCreateFolder: (NSString *) folderName;

- (void) writeDataToFile: (NSData*) data toFile: (NSString *) filePath;

- (NSData *) getDataFromFilePath: (NSString *) filePath;

- (long long) getFileSize: (NSString *) filePath;

@end

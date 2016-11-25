//
//  DownloadingManagment.h
//  LXDownload
//
//  Created by manman on 15/11/12.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadingManagment : NSObject
@property(nonatomic,copy)NSString *resumeDataStr;
@property(nonatomic,copy)NSString *fileSize;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,assign)double progress;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)double time;
@end

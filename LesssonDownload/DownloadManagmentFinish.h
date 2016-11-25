//
//  DownloadManagmentFinish.h
//  LXDownload
//
//  Created by manman on 15/11/12.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManagmentFinish : NSObject
@property(nonatomic,copy)NSString *savePath;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)double time;
@end

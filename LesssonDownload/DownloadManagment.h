//
//  DownloadManagment.h
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"
@interface DownloadManagment : NSObject


//初始化方法
+(instancetype)shareDownloadManagment;


//根据URL添加一个下载类
-(Download *)addDownloadWithURL:(NSString *)url;

//根据URL找到一个下载类
-(Download *)findDownWithURl:(NSString *)url;

//返回所有正在下载的类
-(NSArray *)allDownload;
@end

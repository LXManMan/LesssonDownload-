//
//  LXDB.h
//  LXDownload
//
//  Created by chuanglong02 on 16/11/24.
//  Copyright © 2016年 lanou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManagmentFinish.h"
#import "DownloadingManagment.h"
#import "FMDatabase.h"
@interface LXDB : NSObject
+(FMDatabase *)creatDatabase;


//返回所有正在下载的数据
+(NSArray *)allDownloadFinish;

//返回所有下载完成的数据
+(NSArray *)alldownloading;

//添加一个下载完成的数据（内部已实现对正在下载的删除）
+(void)addDownloadFinishWithFinish:(DownloadManagmentFinish *)finish;

//添加一个正在下载的过程
+(void)addDownloadingWithDownloading:(DownloadingManagment *)downloading;

//根据url 找到一个下载完成的数据
+(DownloadManagmentFinish *)findDownloadFinishWithURL:(NSString *)url;


//根据url找到一个正在下载的数据
+(DownloadingManagment *)findDownloadingWithURL:(NSString *)url;


//根据url 删除一个下载完成的数据
+(void)deleteDownloadFinishWithURL:(NSString *)url;

//根据url 删除一个正在下载的数据
+(void)deleteDownloadingWithURL:(NSString *)url;

//根据url改变一个下载中的 进度显示
+(void)updateDownloadProgress :(double) progress WithURL: (NSString *)url;
@end

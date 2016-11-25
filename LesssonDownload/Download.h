//
//  Download.h
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import <UIKit/UIKit.h>
//下载完成后调用的block
typedef void(^DownloadFinish) (NSString* savePath);

//下载中的block
typedef void(^DownLoading) (double progress,double bytesWritten);


//下载完成的回调方法、（用户不要使用，系统内部使用，目的是使该对象被销毁，使用以后会造成无法被销毁）
typedef void(^DownloadComplted) (NSString *url);

@interface Download : NSObject<NSURLSessionDownloadDelegate>

@property(nonatomic,strong,readonly)NSString *url;//返回该下载类的url
// 根据url创建一个下载类
-(instancetype)initwithURL:(NSString *)url;


//下载中的状态 Block回调
-(void)downloadFinish:(DownloadFinish)downloadFinish downloading:(DownLoading)downloading;

//下载完成的回调方法、（用户不要使用，系统内部使用，目的是使该对象被销毁，使用以后会造成无法被销毁
-(void)downloadComlted:(DownloadComplted)downloadComplted ;
//__deprecated_msg("⚠️使用此方法后，会造成内存泄露，此方法是系统内部使用的");

//开始 继续
-(void)resume;

//暂停
-(void)suspend;
@end

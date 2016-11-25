//
//  Download.m
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import "Download.h"
#import "DownloadingManagment.h"
#import "LXDB.h"
#import "DownloadManagmentFinish.h"
@interface Download()

@property(nonatomic,strong)NSURLSessionDownloadTask *task;
@property(nonatomic,strong)NSURLSession *session;//定义为属性
// 定义两个Block属性
@property(nonatomic,copy)DownLoading downloading;
@property(nonatomic,copy)DownloadFinish downloadFinish;
@property(nonatomic,copy)DownloadComplted downloadComplted;
@end
@implementation Download
{
    BOOL _isFirst;//第一次走下载进度的时候，进行暂停保存数据;
}
-(void)dealloc
{
    
}
-(instancetype)initwithURL:(NSString *)url
{
    if ([super init]) {
        _url = url;
        self.session =[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    //先去数据库中查找是否已经下载了，如果已经下载了，我们就把_isFirst 赋值为YES ，防止我们重复添加 数据
        _isFirst =  [LXDB findDownloadingWithURL:self.url];
    //如果已经下载了就更换我们的task
        
        self.task =[self.session  downloadTaskWithURL:[NSURL URLWithString:url]];
        
        if (_isFirst) {
            NSData *data =[self resumeDataWithURL:self.url];
            self.task =[self.session downloadTaskWithResumeData:data];
            [self.task resume];
        }
       
      
    }
    
    return self;
}
-(NSData *)resumeDataWithURL:(NSString *)url
{
    //1.找到下载中的model
    DownloadingManagment *downloading = [LXDB findDownloadingWithURL:url];
    //2.获取当前下载文件的大小
    NSFileManager *fm =[NSFileManager defaultManager];
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *nowFileSize =  [NSString stringWithFormat:@"%llu", [fm attributesOfItemAtPath:[tmpDir stringByAppendingString:downloading.filePath] error:nil].fileSize ];
    NSLog(@"nowFileSize ========>%@",nowFileSize);

       //3.对resumeDataStr 进行替换
    downloading.resumeDataStr = [downloading.resumeDataStr stringByReplacingOccurrencesOfString:downloading.fileSize withString:nowFileSize];
    //4.生成NSData 。进行返回
    return [downloading.resumeDataStr dataUsingEncoding:NSUTF8StringEncoding];
    
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //bytesWritten 本次下载的字节数 下载速度
    // totalBytesWritten 一共下载了多少的字节数
    //totalBytesExpectedToWrite 总字节数
    
    float progress =(float)totalBytesWritten /totalBytesExpectedToWrite;
   // NSLog(@"%f",progress);
    //定义一个BOOL 值 NO的时候，进行暂停，暂停的时候，把resumeData解析保存，然后把值设置为YES ，让它继续开始下载，就不会走这个暂停方法了；
    if (_isFirst  ==NO) {
        //执行暂停方法
        [self cancelDownloadTask];
        _isFirst =YES;
        
    }
 
    // 对数据库中的下载进度做一个更新
    [LXDB updateDownloadProgress:(double)(progress *100) WithURL:self.url];

   
    //block回调
    if (self.downloading) {
        self.downloading((double)progress*100,(double)bytesWritten);
    }
    
   }
#pragma mark取消task 方法
-(void)cancelDownloadTask
{
    __weak typeof(self)vc = self;
    
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        
        // 解析保存resumeData;
        [self parsingResumeData:resumeData];
        // 继续开始下载
        vc.task = [self.session downloadTaskWithResumeData:resumeData];
        [vc.task resume];
     
    }];
}
#pragma mark --- 解析保存resumeData
-(void)parsingResumeData:(NSData *)resumeData
{
    //截取fileSize字符串
    NSString *resumeDataStr =[[NSString alloc]initWithData:resumeData encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",resumeDataStr);
    NSString *fileSize =   [[resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"]lastObject];
   
    fileSize = [fileSize componentsSeparatedByString:@"</integer>"].firstObject;
    
    //截取filePath字符串
    NSString *filePath =[resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject; //NSURLSessionResumeInfoLocalPath
    filePath = [filePath componentsSeparatedByString:@"</string>"].firstObject;
    // NSLog(@"filePath ==%@",filePath);
    
    //进行保存到数据库
    DownloadingManagment *downloading =[[DownloadingManagment alloc]init];
    downloading.resumeDataStr = resumeDataStr;
    downloading.filePath = filePath;
    downloading.fileSize =fileSize;
    downloading.url = self.url;
    
    //保存数据库
    [LXDB addDownloadingWithDownloading:downloading];
    
    
    
    //我们需要数据库保存当前的信息
    /*
     
     1.resumeDataStr（NSString保存我们resumeData的数据 取出的时候做一个转码
     2. filePath  (NSString) 我们要找到文件的路径 并且求出大小。做替换
     3. fileSize  （int）     保存暂停下载后的resumeData的保存文件的大小。要知道和谁做替换
     4. progress  （double）  下载的进度是多少
     5. url      （NSString） 唯一标示，让我们知道在哪里能找到这条数据
     6. time        （double）     添加下载的时间戳。（创建数据库的时候，都带这个属性。一定会用到，比如我们要做一个排序）
     
     */
    
    //下载完成需要的属性
    /*
     1.url      （NSString） 唯一标示，让我们知道在哪里能找到这条数据
     2.savePath (NSString) 保存的路径
     3.time     （duoble）时间戳 用来排序
     4.
     
     */

}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask , YES)firstObject];
   NSString * savePath =[cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm moveItemAtPath:location.path toPath:savePath error:nil];
    
    
    //4保存数据库
    DownloadManagmentFinish *finish =[[DownloadManagmentFinish alloc]init];
    finish.url =self.url;
    finish.savePath = savePath;
    [LXDB addDownloadFinishWithFinish:finish];
    
    
   // NSLog(@"savePath =====%@",savePath);
    
    //block回调 添加一个判断， 如果用户写了实现，那么我就调用
    if (self.downloadFinish) {
        self.downloadFinish(savePath);
    }
    //下载完成后 回调，目的是让到单例不再持有该对象，从而可以删除
    if (self.downloadComplted) {
        self.downloadComplted(_url);
    }
    
}
#pragma mark下载中的状态，Block回调--- 
-(void)downloadFinish:(DownloadFinish)downloadFinish downloading:(DownLoading)downloading
{
    self.downloadFinish = downloadFinish;
    self.downloading =downloading;
}
#pragma mark--下载完成的回调方法、（用户不要使用，系统内部使用，目的是使该对象被销毁，使用以后会造成无法被销毁
-(void)downloadComlted:(DownloadComplted)downloadComplted
{
    self.downloadComplted = downloadComplted;
}
#pragma mark--开始 继续的方法--
-(void)resume
{
    [self.task resume];
}
#pragma mark--暂停的方法---
-(void)suspend
{
    [self.task suspend];
   
    
}
@end

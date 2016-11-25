//
//  ViewController.m
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import "ViewController.h"
#import "Download.h"
#import "DownloadManagment.h"
#import "DB.h"
//http://baobab.cdn.wandoujia.com/1447163643457322070435.mp4
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (weak, nonatomic) IBOutlet UILabel *path;
@property(nonatomic,strong)Download *download;
@end

@implementation ViewController
-(void)dealloc
{
    NSLog(@"销毁");
}
- (IBAction)resume:(id)sender {
    [self.download resume];
}


- (IBAction)suspend:(UIButton *)sender {
    
    [self.download suspend];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //我们创建NSURLSession有几种方法
    /*
    1 单例创建： NSURLSession *session =[NSURLSession sharedSession];
    2 根据 NSURLSessionConfiguration  创建一个对象，NSURLSessionConfiguration 的作用是：指定一个下载完成存放的位置，和下载的类型
     NSURLSessionConfiguration  的初始化方法有哪些，作用是什么?
     1》defaultSessionConfiguration 返回一个默认配置，下载信息保存在硬盘中（沙盒中）
     2》ephemeralSessionConfiguration 下载的时候信息保存在内存中，和缓冲区中。但是程序退出，或者系统断电，文件都会消失
     3》backgroundSessionConfigurationWithIdentifier      开辟一个子线程去下载数据，这个⚠️可能会导致下载失败，因为子线程下载有下载限制
     NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration  defaultSessionConfiguration];
     NSURLSession *session =[NSURLSession sessionWithConfiguration:cfg];
     
    //3根据NSURLSessionConfiguration 创建一个对象，并且指定一个代理，还有一个下载队列
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration  defaultSessionConfiguration];
    NSURLSession *session =[NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    */

//    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration  defaultSessionConfiguration];
//    NSURLSession *session =[NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//     // 创建我们的DownloadTask 有带block 和不带block的
//   self.task= [session downloadTaskWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/1447163643457322070435.mp4"]];
//http://139.129.165.192/video/jk_00011_006_1_0_dh.mp4
    DownloadManagment *downloadManagment =[DownloadManagment shareDownloadManagment];
    
    
//      _download =[[Download alloc]initwithURL:@"http://baobab.cdn.wandoujia.com/1447163643457322070435.mp4"];
//    [_download resume];
    
    self.download = [downloadManagment addDownloadWithURL:@"http://139.129.165.192/video/jk_00011_006_1_0_dh.mp4"];
    [_download resume];
    [_download downloadFinish:^(NSString *savePath) {
        self.path.text = savePath;
        NSLog(@"%@",savePath);
    } downloading:^(double progress, double bytesWritten) {
        self.progress.text = [NSString stringWithFormat:@"%.4f%%",progress];
    }];
    
    
    
}
/*
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // 把下载的文件转移走，不然会被系统删除
    //1.获取沙盒路径
    

     NSString *cache =    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    NSString *savePath =[cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"%@",savePath);
    //2创建NSFileManager进行文件转移
    NSFileManager *fm = [NSFileManager defaultManager];
    //3转移文件
    [fm moveItemAtPath:location.path toPath:savePath error:nil];
}
//完成下载的代理方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //bytesWritten 本次下载的字节数 下载速度
     // totalBytesWritten 一共下载了多少的字节数
    //totalBytesExpectedToWrite 总字节数
    
    float progress =(float)totalBytesWritten /totalBytesExpectedToWrite;
    NSLog(@"%f",progress);
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  DownloadManagment.m
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import "DownloadManagment.h"
#import "LXDB.h"
@interface DownloadManagment ()
@property(nonatomic,strong)NSMutableDictionary *downloadingDic;

@end
@implementation DownloadManagment

+(instancetype)shareDownloadManagment
{
    static DownloadManagment *downloadManagment = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManagment = [[DownloadManagment alloc]init];
    });
    return downloadManagment;
}
//初始化方法
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadingDic = [NSMutableDictionary dictionary];
          }
    return self;
}
//根据URL添加一个下载类
-(Download *)addDownloadWithURL:(NSString *)url
{
   
    //先从字典里面取到对应的下载类
    Download *download =self.downloadingDic[url];
    
    if (download ==nil) {
        //如果字典里没有，我们就创建一个
        download = [[Download alloc]initwithURL:url];
        // 添加到我们的字典当中
        [self.downloadingDic setObject:download forKey:url];

    }
    //下载完成以后，让单例不再持有着下载类。从字典里面移除
    [download downloadComlted:^(NSString *url) {
               [self.downloadingDic removeObjectForKey:url];
        NSLog(@"移除对象");
    }];
   
    return download;
}

//根据URL找到一个下载类
-(Download *)findDownWithURl:(NSString *)url
{
    return self.downloadingDic[url];
}

//返回所有正在下载的类
-(NSArray *)allDownload
{
    return self.downloadingDic.allValues;
}
@end

//
//  DB.m
//  LXDownload
//
//  Created by manman on 15/11/12.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import "DB.h"

@implementation DB
+(sqlite3 *)open
{
    //创建我们的sqlite文件
    static sqlite3 *db =nil;
    if (db) {
        return db;
    }
    // 创建要保持的数据库文件的地址
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    NSString *sqlPath =[doc stringByAppendingPathComponent:@"downloadManagment.sqlite"];
    
    //判断该目录下是否有文件，如果没有 我们把工程中的拷贝过来，也可以自己创建一个
    NSFileManager *fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:sqlPath] == NO) { // 如果没有
        NSString *bounldPath = [[NSBundle mainBundle]pathForResource:@"downloadManagment" ofType:@"sqlite"];
        [fm copyItemAtPath:bounldPath toPath:sqlPath error:nil];
    }
    NSLog(@"=======%@",sqlPath);
    // 打开数据库
    sqlite3_open([sqlPath UTF8String], &db);
    return db;
}

+(void)close
{
    sqlite3 *db = [DB open];
    sqlite3_close(db);
    db =nil;
}
//返回所有下载完成的数据
+(NSArray *)allDownloadFinish
{
    sqlite3 *db =[DB open];
    sqlite3_stmt *stmt =nil;
    NSMutableArray *array =nil;
    int resule  =sqlite3_prepare_v2(db, "select * from downloadFinish", -1, &stmt, nil);
    NSLog(@"%d",resule);
    if (resule ==SQLITE_OK) {
        array =[NSMutableArray array];
        while (sqlite3_step(stmt) ==SQLITE_ROW) {
            DownloadManagmentFinish *downloadFinish = [[DownloadManagmentFinish alloc]init];
            
            const unsigned char *cSavePath = sqlite3_column_text(stmt, 0);
            downloadFinish.savePath =[NSString stringWithUTF8String:(const char *)cSavePath];
            
            const unsigned char *cUrl =  sqlite3_column_text(stmt, 1);
            downloadFinish.url =[NSString stringWithUTF8String:(const char *)cUrl];
            
            double time = sqlite3_column_double(stmt, 2);
            downloadFinish.time = time;
            
            [array addObject:downloadFinish];
        }
    }
    sqlite3_finalize(stmt);
    return  array;
}

//返回所有正在下载的数据
+(NSArray *)alldownloading
{
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
    //创建我们的数组
    NSMutableArray *array = nil;
  int resule =  sqlite3_prepare_v2(db, "select * from downloading", -1, &stmt, nil);
    
    if (resule ==SQLITE_OK) {
        array = [NSMutableArray array];// 如果语句通过，初始化我们的数组
        while (sqlite3_step(stmt)==SQLITE_ROW) {
       const unsigned char *cResumeDataStr=  sqlite3_column_text(stmt, 0);
            
            NSString *resumeDataStr = [NSString stringWithUTF8String:(const char *)cResumeDataStr];
            const unsigned char *cFilePath = sqlite3_column_text(stmt, 1);
            NSString *filePath =[NSString stringWithUTF8String:(const char *)cFilePath];
            const unsigned char *cFileSize = sqlite3_column_text(stmt, 2);
            NSString *fileSize =[NSString stringWithUTF8String:(const char *)cFileSize];
            float progress = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cUrl = sqlite3_column_text(stmt, 4);
            NSString *url =[NSString stringWithUTF8String:(const char *)cUrl];
            int time =sqlite3_column_int(stmt, 5);
            
            DownloadingManagment *downloading =[[DownloadingManagment alloc]init];
            NSDictionary *dic = @{@"resumeDataStr":resumeDataStr,@"filePath":filePath,@"fileSize":fileSize,@"url":url,@"progress":@(progress),@"time":@(time)};
            [downloading setValuesForKeysWithDictionary:dic];
            [array addObject:downloading];
        
        }
    }
    sqlite3_finalize(stmt);
    
    
    return array;
    
}

//添加一个下载完成的数据（内部已实现对正在下载的删除）
+(void)addDownloadFinishWithFinish:(DownloadManagmentFinish *)finish
{
    sqlite3 *db =[DB open];
    // 求出当前的时间戳
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *sql =[NSString stringWithFormat:@"insert into downloadFinish values('%@','%@',%f)",finish.savePath,finish.url,time];
   //执行sql语句
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
    //内部删除 正在下载的数据
    [DB deleteDownloadingWithURL:finish.url];
}


//添加一个正在下载的过程
+(void)addDownloadingWithDownloading:(DownloadingManagment *)downloading
{
    sqlite3 *db =[DB open];
    // 求出当前的时间戳
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *sql =[NSString stringWithFormat:@"insert into downloading values('%@','%@','%@',%d,'%@',%f)",downloading.resumeDataStr,downloading.filePath,downloading.fileSize,(int)downloading.progress,downloading.url,time];
    // 执行sql语句
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
    
}

//根据url 找到一个下载完成的数据
+(DownloadManagmentFinish *)findDownloadFinishWithURL:(NSString *)url
{
    sqlite3 *db =[DB open];
    sqlite3_stmt *stmt =nil;
    DownloadManagmentFinish *downloadFinish =nil;
    NSString *sql =[NSString stringWithFormat:@"select *from downloadFinish where url = '%@'",url];
    int resule  =sqlite3_prepare(db,[sql UTF8String] , -1, &stmt, nil);
    NSLog(@"%d",resule);
    if (resule ==SQLITE_OK) {
   
        while (sqlite3_step(stmt) ==SQLITE_ROW) {
            downloadFinish = [[DownloadManagmentFinish alloc]init];
            
            const unsigned char *cSavePath = sqlite3_column_text(stmt, 0);
            downloadFinish.savePath =[NSString stringWithUTF8String:(const char *)cSavePath];
            
            const unsigned char *cUrl =  sqlite3_column_text(stmt, 1);
            downloadFinish.url =[NSString stringWithUTF8String:(const char *)cUrl];
            
            double time = sqlite3_column_double(stmt, 2);
            downloadFinish.time = time;
            
            
        }
    }
    sqlite3_finalize(stmt);
    return  downloadFinish;

}


//根据url找到一个正在下载的数据
+(DownloadingManagment *)findDownloadingWithURL:(NSString *)url
{
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
   
    DownloadingManagment *downloading =nil;
    NSString *sql =[NSString stringWithFormat:@"select *from downloading where url = '%@'",url];
    int resule =  sqlite3_prepare(db, [sql UTF8String], -1, &stmt, nil);
    
    if (resule ==SQLITE_OK) {
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            const unsigned char *cResumeDataStr=  sqlite3_column_text(stmt, 0);
            
            NSString *resumeDataStr = [NSString stringWithUTF8String:(const char *)cResumeDataStr];
            const unsigned char *cFilePath = sqlite3_column_text(stmt, 1);
            NSString *filePath =[NSString stringWithUTF8String:(const char *)cFilePath];
            const unsigned char *cFileSize = sqlite3_column_text(stmt, 2);
            NSString *fileSize =[NSString stringWithUTF8String:(const char *)cFileSize];
            float progress = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cUrl = sqlite3_column_text(stmt, 4);
            NSString *url =[NSString stringWithUTF8String:(const char *)cUrl];
            int time =sqlite3_column_int(stmt, 5);
            
           downloading =[[DownloadingManagment alloc]init];
            NSDictionary *dic = @{@"resumeDataStr":resumeDataStr,@"filePath":filePath,@"fileSize":fileSize,@"url":url,@"progress":@(progress),@"time":@(time)};
            [downloading setValuesForKeysWithDictionary:dic];
            
            
        }
    }
    sqlite3_finalize(stmt);
    
    
    return downloading;
    

}


//根据url 删除一个下载完成的数据
+(void)deleteDownloadFinishWithURL:(NSString *)url
{
    sqlite3 *db =[DB open];
    NSString *sql =[NSString stringWithFormat:@"delete from downloadFinish where url = '%@'",url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//根据url 删除一个正在下载的数据
+(void)deleteDownloadingWithURL:(NSString *)url
{
    sqlite3 *db =[DB open];
    NSString *sql =[NSString stringWithFormat:@"delete from downloading where url = '%@'",url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//根据url改变一个下载中的 进度显示
+(void)updateDownloadProgress :(int) progress WithURL: (NSString *)url
{
    sqlite3 *db =[DB open];
    NSString *sql =[NSString stringWithFormat:@"update downloading set progress =%d where url ='%@'",progress,url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

@end

//
//  LXDB.m
//  LXDownload
//
//  Created by chuanglong02 on 16/11/24.
//  Copyright © 2016年 lanou. All rights reserved.
//

#import "LXDB.h"

#define TableDownloading @"TableDownloading"
#define TableDownFinish @"TableDownFinish"
#define ID @"id"
#define downloadUrl @"url"
#define DownFinishSavePath @"savePath"
#define DownFinishTime @"time"
#define DownloadingTime @"time"
#define DownloadingResumeDataStr @"resumeDataStr"
#define DownloadingFilePath  @"filePath"
#define DownloadingFileSize @"fileSize"
#define downloadingProgress @"progress"
@implementation LXDB
+(FMDatabase *)creatDatabase{
    
    NSString * doc =  PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"LB.sqlite"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    FMDatabase *db;
    if ([fileManager fileExistsAtPath:path] == NO) {
        // create it
        db = [FMDatabase databaseWithPath:path];
        if ([db open]) {
            NSString *downloadingSql =   [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' DOUBLE,'%@' DOUBLE)",TableDownloading,ID,downloadUrl,DownloadingResumeDataStr,DownloadingFilePath,DownloadingFileSize,DownloadingTime,downloadingProgress];
            BOOL res = [db executeUpdate:downloadingSql];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"succ to creating db table");
            }
            NSString *downloadFinishSql =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT,'%@' TEXT, '%@' DOUBLE)",TableDownFinish,ID,downloadUrl,DownFinishSavePath,DownFinishTime];
            BOOL resF = [db executeUpdate:downloadFinishSql];
            if (!resF) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"succ to creating db table");
            }

            [db close];
        } else {
            NSLog(@"error when open db");
        }
    }else
    {
        db =[FMDatabase databaseWithPath:path];
    }

    return db;
}


//返回所有正在下载的数据
+(NSArray *)allDownloadFinish{
    
    NSMutableArray *array =[NSMutableArray array];
    FMDatabase *db =[LXDB creatDatabase];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select from *%@",TableDownFinish];
        FMResultSet *rs =[db executeQuery:sql];
        while ([rs next]) {
            DownloadManagmentFinish *finish =[[DownloadManagmentFinish alloc]init];
            finish.savePath =[rs stringForColumn:DownFinishSavePath];
          finish.url =[rs stringForColumn:downloadUrl];
           finish.time = [rs doubleForColumn:DownFinishTime];
           
            [array addObject:finish];
        }
    }
    return array;
}

//返回所有正在的数据
+(NSArray *)alldownloading{
    NSMutableArray *array =[NSMutableArray array];
    FMDatabase *db =[LXDB creatDatabase];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select from *%@",TableDownloading];
        FMResultSet *rs =[db executeQuery:sql];
        while ([rs next]) {
            
            DownloadingManagment *downloading =[[DownloadingManagment alloc]init];
            downloading.filePath =[rs stringForColumn:DownloadingFilePath];
            downloading.url =[rs stringForColumn:downloadUrl];
            downloading.time = [rs doubleForColumn:DownloadingTime];
            downloading.fileSize = [rs stringForColumn:DownloadingFileSize];
            downloading.progress = [rs doubleForColumn:downloadingProgress];
            downloading.resumeDataStr = [rs stringForColumn:DownloadingResumeDataStr];
            
            [array addObject:downloading];
        }
    }
    return array;
}


//添加一个下载完成的数据（内部已实现对正在下载的删除）
+(void)addDownloadFinishWithFinish:(DownloadManagmentFinish *)finish{

  
    //内部删除 正在下载的数据
    FMDatabase *db =[LXDB creatDatabase];
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    if ([db open]) {

        NSString *sql =[NSString stringWithFormat:
                        @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', '%@', '%@')",
                        TableDownFinish,downloadUrl,DownFinishSavePath,DownFinishTime, finish.url, finish.savePath, @(time)];
        
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }

    [LXDB deleteDownloadingWithURL:finish.url];
    
}


//添加一个正在下载的过程
+(void)addDownloadingWithDownloading:(DownloadingManagment *)downloading{
    
    
    //内部删除 正在下载的数据
    FMDatabase *db =[LXDB creatDatabase];
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    if ([db open]) {
        
       
        NSString *sql =  [NSString stringWithFormat:
                          @"INSERT INTO '%@' ('%@', '%@', '%@','%@','%@','%@') VALUES ('%@', '%@', '%@','%@','%@','%@')",
                          TableDownloading,downloadUrl,DownloadingResumeDataStr,DownloadingFilePath,DownloadingFileSize,DownloadingTime,downloadingProgress, downloading.url, downloading.resumeDataStr, downloading.filePath, downloading.fileSize, @(time), @(downloading.progress)];
        
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }

    
}

//根据url 找到一个下载完成的数据
+(DownloadManagmentFinish *)findDownloadFinishWithURL:(NSString *)url{
    
   
    NSString *sql =[NSString stringWithFormat:@"select *from %@ where url = '%@'",TableDownFinish,url];
    FMDatabase *db =[LXDB creatDatabase];
     DownloadManagmentFinish *downloadFinish =nil;
    if ([db open]) {
        FMResultSet *rs =[db executeQuery:sql];
        while ([rs next]) {
            downloadFinish =[[DownloadManagmentFinish alloc]init];
            downloadFinish.savePath =[rs stringForColumn:DownFinishSavePath];
            downloadFinish.url =[rs stringForColumn:downloadUrl];
            downloadFinish.time = [rs doubleForColumn:DownFinishTime];
            
        }
        [db close];
    }
   
    
    return  downloadFinish;
}



//根据url找到一个正在下载的数据
+(DownloadingManagment *)findDownloadingWithURL:(NSString *)url{
    
    FMDatabase *db =[LXDB creatDatabase];
    
    NSString *sql =[NSString stringWithFormat:@"select *from %@ where url = '%@'",TableDownloading,url];
   
    DownloadingManagment *downloading =nil;
    if ([db open]) {
        FMResultSet *rs =[db executeQuery:sql];
        while ([rs next]) {
            
            downloading =[[DownloadingManagment alloc]init];
            downloading.filePath =[rs stringForColumn:DownloadingFilePath];
            downloading.url =[rs stringForColumn:downloadUrl];
            downloading.time = [rs doubleForColumn:DownloadingTime];
            downloading.fileSize = [rs stringForColumn:DownloadingFileSize];
            downloading.progress = [rs doubleForColumn:downloadingProgress];
            downloading.resumeDataStr = [rs stringForColumn:DownloadingResumeDataStr];
        }
        [db close];
    }
    
    
    return  downloading;
}



//根据url 删除一个下载完成的数据
+(void)deleteDownloadFinishWithURL:(NSString *)url{
    
    FMDatabase *db =[LXDB creatDatabase];
   
    if ([db open]) {
         NSString *sql =[NSString stringWithFormat:@"delete from %@ where url = '%@'",TableDownFinish,url];
        BOOL res =[db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to delete db data");
        } else {
            NSLog(@"succ to deleta db data");
        }
        [db close];
    }
    
}


//根据url 删除一个正在下载的数据
+(void)deleteDownloadingWithURL:(NSString *)url{
    
    FMDatabase *db =[LXDB creatDatabase];
    
    if ([db open]) {
        NSString *sql =[NSString stringWithFormat:@"delete from %@ where url = '%@'",TableDownloading,url];
        BOOL res =[db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to delete db data");
        } else {
            NSLog(@"succ to deleta db data");
        }
        [db close];
    }

}


//根据url改变一个下载中的 进度显示
+(void)updateDownloadProgress :(double) progress WithURL: (NSString *)url{
    
    FMDatabase *db =[LXDB creatDatabase];
    
    if ([db open]) {
        NSString *sql =[NSString stringWithFormat:@"update %@ set progress =%@ where url ='%@'",TableDownloading,@(progress),url];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
//            NSLog(@"error to update db data");
        } else {
//            NSLog(@"succ to update db data");
        }
        [db close];
    }
  
    
}

@end

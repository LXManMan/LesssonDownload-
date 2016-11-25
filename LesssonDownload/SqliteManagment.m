//
//  SqliteManagment.m
//  LXDownload
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import "SqliteManagment.h"
static sqlite3 *db = nil;
@implementation SqliteManagment
-(NSString *)documentPathWithSqliteName:(NSString *)sqliteName
{
    return  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:sqliteName];
}
+(SqliteManagment *)shareInstance
{
    static SqliteManagment *sqlite = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlite = [[SqliteManagment alloc]init];
    });
    return sqlite;
}
//打开数据库
-(sqlite3 *)openDB
{
    if (db !=nil) {
        return db;
    }
    NSString *filePath = [self documentPathWithSqliteName:@"Eyes.sqlite"];
    sqlite3_open([filePath UTF8String], &db);
    NSLog(@"filePath =%@",filePath);
    return db;
}
-(void)creatTableWithTableName:(NSString *)tableName sql:(NSString *)sql
{
    db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *string = [NSString stringWithFormat:sql,tableName];
    NSInteger flag = sqlite3_prepare_v2(db, [string UTF8String], -1, &stmt, nil);
    NSLog(@"数据表 flag = %ld",flag);
    if (SQLITE_OK == flag) {
        sqlite3_step(stmt);
    
    }
    sqlite3_finalize(stmt);
    [self closeDB];
}
#pragma mark--在 当前信息表中插入数据--
-(void)insertCurrentSaveDataWithTableName:(NSString *)tableName resumeDataStr:(NSString *)resumeDataStr filePath:(NSString *)filePath fileSize:(int)fileSize progress:(float)progress url:(NSString *)url time:(double)time myID:(int)myID
{
    db = [self openDB];
    sqlite3_stmt *stmt = nil;
        NSString *string  =[NSString stringWithFormat:@"insert into %@(resumeDataStr,filePath,fileSize,progress,url,time,myID)values(?,?,?,?,?,?,?)",tableName];
    NSInteger flag = sqlite3_prepare_v2(db, [string UTF8String], -1, &stmt, nil);
    NSLog(@"在当前信息表中插入数据 == %ld",flag);
    if (SQLITE_OK == flag) {
        sqlite3_bind_text(stmt, 1, [resumeDataStr UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 2, [filePath UTF8String], -1, nil);
        sqlite3_bind_int(stmt, 3, (int)fileSize);
        sqlite3_bind_double(stmt, 4, (double)progress);
        sqlite3_bind_text(stmt, 5, [url UTF8String], -1, nil);
        sqlite3_bind_double(stmt, 6, (double)time);
        sqlite3_bind_int(stmt, 7, (int)myID);
        //指定指令集
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    [self openDB];
}
#pragma mark---在下载完成表中插入数据--
-(void)insertDownloadCompleteDataWithTableName:(NSString *)tableName url:(NSString *)url savePath:(NSString *)savePath time:(double)time myID:(int)myID
{
    db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *string =[NSString stringWithFormat:@"insert into %@(url,savePath,time,myID)values(?,?,?,?)",tableName];
   NSInteger flag = sqlite3_prepare_v2(db, [string UTF8String], -1, &stmt, nil);
    NSLog(@"下载表中插入数据==%ld",flag);
    if (SQLITE_OK == flag) {
        sqlite3_bind_text(stmt, 1, [url UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 2, [savePath UTF8String], -1, nil);
        sqlite3_bind_double(stmt, 3, (double)time);
        sqlite3_bind_int(stmt, 4, (int)myID);
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    [self closeDB];
}

#pragma mark-- 关闭数据库--- 
-(void)closeDB
{
    sqlite3_close(db);
    db =nil;
}
@end

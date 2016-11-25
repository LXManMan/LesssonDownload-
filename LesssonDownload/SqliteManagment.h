//

 

 
//
//  Created by manman on 15/11/11.
//  Copyright (c) 2015年 manman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqliteManagment : NSObject
+(SqliteManagment *)shareInstance;
//打开数据库
-(sqlite3 *)openDB;
-(void)creatTableWithTableName:(NSString *)tableName sql:(NSString *)sql;
#pragma mark--在 当前信息表中插入数据--
-(void)insertCurrentSaveDataWithTableName:(NSString *)tableName resumeDataStr:(NSString *)resumeDataStr filePath:(NSString *)filePath fileSize:(int)fileSize progress:(float)progress url:(NSString *)url time:(double)time myID:(int)myID;
#pragma mark---在下载完成表中插入数据--
-(void)insertDownloadCompleteDataWithTableName:(NSString *)tableName url:(NSString *)url savePath:(NSString *)savePath time:(double)time myID:(int)myID;

@end


/*
  //我们需要数据库保存当前的信息
  1.resumeDataStr（NSString保存我们resumeData的数据 取出的时候做一个转码
 2. filePath  (NSString) 我们要找到文件的路径 并且求出大小。做替换
 3. fileSize  （int）     保存暂停下载后的resumeData的保存文件的大小。要知道和谁做替换
 4. progress  （float）  下载的进度是多少
 5. url      （NSString） 唯一标示，让我们知道在哪里能找到这条数据
 6. time        （double）     添加下载的时间戳。（创建数据库的时候，都带这个属性。一定会用到，比如我们要做一个排序）
 
 
 1.url      （NSString） 唯一标示，让我们知道在哪里能找到这条数据
 2.savePath (NSString) 保存的路径
 3.time     （duoble）时间戳 用来排序
 4.
 
 */
#import "AppDelegate.h"
#import "SqliteManagment.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //打开数据库
//    [[SqliteManagment shareInstance]openDB];
//    
//    [[SqliteManagment shareInstance]creatTableWithTableName:@"current" sql:@"create table if not exists %@(ID integer primary key autoincrement,resumeDataStr text,filePath text,fileSize int,progress float, url text,time double, myID int)"];
//    
//    [[SqliteManagment shareInstance]insertCurrentSaveDataWithTableName:@"current" resumeDataStr:@"a" filePath:@"b" fileSize:18 progress:25.0 url:@"c" time:25.0 myID:20];
//    [[SqliteManagment shareInstance]creatTableWithTableName:@"complete" sql:@"create table if not exists %@(ID integer primary key autoincrement,url text,savePath text,time double,myID int)"];
//    [[SqliteManagment shareInstance]insertDownloadCompleteDataWithTableName:@"complete" url:@"" savePath:@"" time:20.0 myID:25.0];
     return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

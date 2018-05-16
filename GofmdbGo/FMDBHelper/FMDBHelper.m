//
//  FMDBHelper.m
//  GofmdbGo
//
//  Created by Macmafia on 2018/5/16.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "FMDBHelper.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

static FMDBHelper *mHelper = nil;

@interface FMDBHelper ()
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSURL *filePath;
@end

@implementation FMDBHelper

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!mHelper) {
            mHelper = [[self alloc] init];
        }
    });
    return mHelper;
}

-(NSURL *)filePath
{
    if (!_filePath) {
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _filePath = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"Person.sqlite"] isDirectory:NO];
    }
    return _filePath;
}

- (FMDatabase *)db
{
    if (!_db) {
        _db = [FMDatabase databaseWithURL:self.filePath];
        BOOL result = [_db open];
        if (!result) {
            NSLog(@"++++开启数据库失败");
        }
        [_db close];//注意 这里也可以不关闭，因为频繁的关闭会导致额外的性能开销，且应用关闭后数据库会自动关闭
    }
    return _db;
}

- (void)createTable
{
    [self.db open];
    //数据库中创建表（可创建多张）
    NSString *sql = @"create table if not exists t_student ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'name' TEXT NOT NULL, 'phone' TEXT NOT NULL,'score' INTEGER NOT NULL)";
    //执行更新操作 此处database直接操作，不考虑多线程问题，多线程问题 用FMDatabaseQueue。
    //每次数据库操作之后都会返回bool数值，YES，表示success，NO，表示fail,可以通过 @see lastError @see lastErrorCode @see lastErrorMessage
    BOOL result2 = [self.db executeUpdate:sql];
    if (result2) {
        NSLog(@"create table success");
    }
    [self.db close];
}

- (void)insertData
{
    [self.db open];
    BOOL result = [self.db executeUpdate:@"insert into 't_student'(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:@[@(113),@"x3",@"13",@(53)]];
    if (result) {
        NSLog(@"insert into 't_studet' success");
    }
    [self.db close];
}

- (void)updateData
{
    [self.db open];
    BOOL result = [self.db executeUpdate:@"update 't_student' set ID = ? where name = ?" withArgumentsInArray:@[@(113),@"x3"]];
    if (result) {
        NSLog(@"update 't_student' success");
    }
    [self.db close];
}

- (void)deleteData
{
    [self.db open];
    BOOL result = [self.db executeUpdate:@"delete from 't_student' where ID = ?" withArgumentsInArray:@[@113]];
    if (result) {
        NSLog(@"delete from 't_student' success");
    }
    [self.db close];
}

- (void)queryData
{
    [self.db open];
    FMResultSet *result = [self.db executeQuery:@"select * from 't_student' where ID = ?" withArgumentsInArray:@[@(113)]];
    while ([result next]) {
        int ID = [result intForColumn:@"ID"];
        NSString *name = [result stringForColumn:@"name"];
        int score = [result intForColumn:@"score"];
        NSLog(@"+++search result:\n name:%@,ID:%d,score:%d",name,ID,score);
    }
    [self.db close];
}

- (void)operatInQueue
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.filePath.path];
    [queue inDatabase:^(FMDatabase *db) {
        //增
        [db executeUpdate:@"insert into 't_student'(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:@[@(112),@"x2",@"12",@(52)]];
        [db executeUpdate:@"insert into 't_student'(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:@[@(113),@"x3",@"13",@(53)]];
        //删
        [db executeUpdate:@"delete from 't_student' where ID = ?" withArgumentsInArray:@[@113]];
        //改
        [db executeUpdate:@"update 't_student' set ID = ? where name = ?" withArgumentsInArray:@[@(113),@"x3"]];
        //查
        FMResultSet *result = [db executeQuery:@"select * from 't_student' where ID = ?" withArgumentsInArray:@[@(113)]];
        while ([result next]) {
            int ID = [result intForColumn:@"ID"];
            NSString *name = [result stringForColumn:@"name"];
            int score = [result intForColumn:@"score"];
            NSLog(@"+++search result:\n name:%@,ID:%d,score:%d",name,ID,score);
        }
    }];
}

@end

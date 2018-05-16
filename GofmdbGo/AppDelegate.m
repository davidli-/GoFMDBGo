//
//  AppDelegate.m
//  GofmdbGo
//
//  Created by Macmafia on 2018/5/16.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDBHelper.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //CoreData
    [self insertData];
    [self fetchData];
    
    /*FMDB：
     iOS中使用C语言函数对原生SQLite数据库进行增删改查操作，复杂麻烦，于是，就出现了一系列将SQLite API封装的库，如FMDB
     FMDB是针对libsqlite3框架进行封装的三方，它以OC的方式封装了SQLite的C语言的API
     FMDB的优点是：
     (1) 使用时面向对象，避免了复杂的C语言代码
     (2) 对比苹果自带的Core Data框架，更加轻量级和灵活
     (3) 提供多线程安全处理数据库操作方法，保证多线程安全跟数据准确性
     */
    FMDBHelper *helper = [FMDBHelper shareInstance];
//    [helper createTable];
//    [helper insertData];
//    [helper queryData];
//    [helper updateData];
//    [helper deleteData];
    [helper operatInQueue];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"GofmdbGo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                }
            }];
        }
    }
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
}



#pragma mark -Business
- (void)insertData
{
    NSManagedObjectContext *context1 = [self.persistentContainer viewContext];
    for(int i = 0; i < 5; i++)
    {
        //创建CoreData模型，注意这里的参数上下文是基于多线程的
        NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context1];
        //赋值
        [person setValue:[NSString stringWithFormat:@"Name+%d",i] forKey:@"name"];
        [person setValue:@(i) forKey:@"age"];
    }
    //    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * contenxtInBlock) {
    NSError *error;
    [context1 save:&error];//这里不能使用block中的contenxtInBlock，而必须要使用上面的context1（在哪一个上下文中添加，就在哪一个上下文中保存）
    if (error) {
        NSLog(@"++++save 出错！");
    }
    //    }];
}

- (void)fetchData
{
    NSManagedObjectContext *context1 = [self.persistentContainer viewContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context1];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name='Name+0'"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@",@"*Name*"];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    //    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * contextInblock) {
    NSError *error = nil;
    NSArray *fetchedObjects = [context1 executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count) {
        NSInteger count = fetchedObjects.count;
        for (int i = 0; i < count; i++) {
            NSManagedObject *obj = fetchedObjects[i];
            NSString *name = [obj valueForKey:@"name"];
            NSLog(@"+++++Name:%@",name);
        }
    }
    //    }];
}
@end

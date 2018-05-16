//
//  FMDBHelper.h
//  GofmdbGo
//
//  Created by Macmafia on 2018/5/16.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBHelper : NSObject

+ (instancetype)shareInstance;
- (void)createTable;
- (void)insertData;
- (void)updateData;
- (void)deleteData;
- (void)queryData;
- (void)operatInQueue;
@end

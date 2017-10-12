//
//  RelateModel.m
//  cztvNewsiPhone
//
//  Created by heJF on 2017/1/22.
//  Copyright © 2017年 cztv. All rights reserved.
//

#import "RelateModel.h"

@implementation RelateModel
+ (instancetype)relateModelWithDic:(NSDictionary *)dic{
    RelateModel *relateModel = [[RelateModel alloc] init];
    relateModel.contId = [dic objectForKey:@"contId"];
    relateModel.name = [dic objectForKey:@"name"];
    return relateModel;
}
@end

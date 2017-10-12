//
//  RelateModel.h
//  cztvNewsiPhone
//
//  Created by heJF on 2017/1/22.
//  Copyright © 2017年 cztv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelateModel : NSObject
@property (nonatomic, copy) NSString *contId, *name;
+ (instancetype)relateModelWithDic:(NSDictionary *)dic;
@end

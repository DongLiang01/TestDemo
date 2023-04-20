//
//  SASRouterModel.h
//  RightBTC
//
//  Created by 董良 on 2022/9/14.
//  Copyright © 2022 LYX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SASRouterJumpType_push = 1,
    SASRouterJumpType_present = 2,
} SASRouterJumpType;

#define kJumpType @"jumptype"

@interface SASRouterModel : NSObject

/**
 路由文件里的url, schema sas-原生跳转 http-外部浏览器
 */
@property (nonatomic, copy) NSString * _Nonnull url;

/**
 实际跳转的URL
 */
@property (nonatomic, copy) NSString * _Nonnull targetURL;

/**
 URL转换后的对象
 */
@property (nonatomic, strong) NSURLComponents *_Nonnull targetURLComponents;

/**
 控制器类名
 */
@property (nonatomic, copy) NSString * _Nullable className;


/**
 跳转到原生的参数
 */
@property (nonatomic, strong) NSDictionary * _Nullable params;

/**
 跳转方式：1-push 2-present，默认是1
 */
@property (nonatomic, assign) SASRouterJumpType jumpType;


- (instancetype _Nullable)initWithDic:(NSDictionary *_Nonnull)dic;


@end

NS_ASSUME_NONNULL_END

//
//  SASRouterManager.h
//  RightBTC
//
//  Created by 董良 on 2022/9/14.
//  Copyright © 2022 LYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 "CFDLoginViewController":"sas://chimchim.top/login?*jumptype=2"
 参数（例如jumptype）前面加个*，标识它是一个必传字段
 scheme: 必须是sas://
 host: chimchim.top
 模块名：例子中的login
 */

// 类名与url对应关系文件
#define kRouterNameList @"router_name_list"
// 模块路由文件
#define kRouterClassList @"router_class_list"
// 可以识别的urlscheme
#define kSASSheme @"sas"
// 切换tabbar
#define switchTabbar(index) [NSString stringWithFormat:@"sas://chimchim.top/tabbar?index=%d",index]
//  webView
#define kWebViewRouterUrl(url) kWebViewRouterUrlWithParams(url, NO, NO, NO)
#define kWebViewRouterUrlPop(url, isTopPop) kWebViewRouterUrlWithParams(url, isTopPop, NO, NO)
#define kWebViewRouterUrlWithParams(url,isTopPop,NAVHIDDEN,isVersetPerson) [NSString stringWithFormat:@"sas://chimchim.top/web?jumptype=1&url=%@&isTopPop=%@&NAVHIDDEN=%@&isVersetPerson=%@",url,@(isTopPop),@(NAVHIDDEN),@(isVersetPerson)]
// routerUrl
#define kRouterUrl(url) [NSString stringWithFormat:@"sas://chimchim.top/%@",url]

//按照类名pop控制器时，可以设置升序还是降序，默认是升序，也就是从下标为0的控制开始查找
typedef enum : NSUInteger {
    SASRouterTargetVCNameSortType_asc = 1,  //升序
    SASRouterTargetVCNameSortType_desc = 2,  //降序
} SASRouterTargetVCNameSortType;

@interface SASRouterManager : NSObject

+(instancetype)sharedRouterManager;
#pragma mark 获取顶层控制器
+(UIViewController *)topViewController;

/**
 根据类名进行路由跳转
 
 @param name 路由名
 @param block 回调，push的话，navigationController必须使用XCNavigationController才会执行回调
 */
- (void)routerWithRouterName:(NSString *_Nonnull)name complete:(void(^_Nullable)(BOOL finished))block;

/**
 根据类名进行路由跳转，有额外参数

 @param name 路由名
 @param params 请求参数
 @param block 回调，push的话，navigationController必须使用XCNavigationController才会执行回调
 */
- (void)routerWithRouterName:(NSString *_Nonnull)name params:(NSDictionary *_Nullable)params complete:(void(^_Nullable)(BOOL finished))block;

/**
 根据路由url进行跳转
 
 @param url 实际的跳转url
 @param block 回调，push的话，navigationController必须使用XCNavigationController才会执行回调
 */
- (void)routerWithURL:(NSString *_Nonnull)url complete:(void(^_Nullable)(BOOL finished))block;

/**
 根据路由url进行跳转，有额外参数

 @param url 实际跳转url
 @param params 请求参数
 @param block 回调，push的话，navigationController必须使用XCNavigationController才会执行回调
 */
- (void)routerWithURL:(NSString *_Nonnull)url params:(NSDictionary *_Nullable)params complete:(void(^_Nullable)(BOOL finished))block;

/**
 路由返回上一级
 */
- (void)popRouter;
- (void)popRouterAnimated:(BOOL)animated;

/**
 路由返回上一级并回传参数给上一级页面
 */
- (void)popRouterWithParams:(NSDictionary *_Nullable)params;
- (void)popRouterWithParams:(NSDictionary *_Nullable)params animated:(BOOL)animated;

/**
 返回到第N级路由

 @param index 返回层级
 */
- (void)popRouterToIndex:(NSInteger)index;
- (void)popRouterToIndex:(NSInteger)index animated:(BOOL)animated;

/**
 返回到第N级路由，带参数

 @param index 返回层级
 */
- (void)popRouterToIndex:(NSInteger)index params:(NSDictionary *_Nullable)params;
- (void)popRouterToIndex:(NSInteger)index params:(NSDictionary *_Nullable)params animated:(BOOL)animated;

/**
 向上返回至指定名称的路由页面
 @param targetVCName 页面名称
 */
- (void)popRouterWithTargetVCName:(NSString *_Nonnull)targetVCName;
- (void)popRouterWithTargetVCName:(NSString *_Nonnull)targetVCName animated:(BOOL)animated;

/**
 向上返回至指定名称的路由页面,带参数
 @param targetVCName 页面名称
 */
- (void)popRouterWithTargetVCName:(NSString *_Nonnull)targetVCName params:(NSDictionary *_Nullable)params;
- (void)popRouterWithTargetVCName:(NSString *_Nonnull)targetVCName params:(NSDictionary *_Nullable)params animated:(BOOL)animated;

- (void)popRouterWithTargetVCName:(NSString *_Nonnull)targetVCName params:(NSDictionary *_Nullable)params animated:(BOOL)animated sort:(SASRouterTargetVCNameSortType)sort;

@end

NS_ASSUME_NONNULL_END

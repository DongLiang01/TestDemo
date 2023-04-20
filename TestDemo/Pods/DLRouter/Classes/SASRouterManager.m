//
//  SASRouterManager.m
//  RightBTC
//
//  Created by 董良 on 2022/9/14.
//  Copyright © 2022 LYX. All rights reserved.
//

#import "SASRouterManager.h"
#import "SASRouterModel.h"
#import <SafariServices/SafariServices.h>
#import "SASRouteNotFoundViewController.h"
#import "XCNavigationController.h"

@interface SASRouterManager()

/**
 路由名跟路由url映射文件
 */
@property (nonatomic, strong) NSDictionary *routerNameDic;

/**
 路由url跟本地类名映射文件
 */
@property (nonatomic, strong) NSDictionary *routes;

//跳转时找不到类时，默认的404空页面
@property (nonatomic, strong) SASRouteNotFoundViewController *notFoundViewController;

@end

@implementation SASRouterManager

+(instancetype)sharedRouterManager{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static SASRouterManager *single = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        single = [super allocWithZone:zone];
    });
    return single;
}

#pragma mark 加载路由名与路由url映射文件
- (NSDictionary *)sas_routerNames {
    // 读取缓存配置文件是否可用
    NSDictionary *dic = [self sas_loadJSONFileWithPath:[self sas_fullWithfileName:kRouterNameList]];
    if(!dic) {
        NSAssert(NO, @"主工程尚未配置[%@.json]文件, 或此文件格式不正确",kRouterNameList);
    }
    return dic;
}

- (NSDictionary *)sas_routerModules {
    // 读取缓存配置文件是否可用
    NSDictionary *dic = [self sas_loadJSONFileWithPath:[self sas_fullWithfileName:kRouterClassList]];
    if(!dic) {
        NSAssert(NO, @"主工程尚未配置[%@.json]文件, 或此文件格式不正确",kRouterClassList);
    }
    return dic;
}

- (NSString *)sas_fullWithfileName:(NSString *)fileName {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:fileName ofType:@"json"];
    return path;
}

- (id)sas_loadJSONFileWithPath:(NSString *)path {
    NSError *error = nil;
    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(!result) {
        // 如果读取不到说明未配置文件
        return nil;
    }
//    id routers = [result mj_JSONObject];
    return result;
}

- (id)mj_JSONObject
{
    return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}


#pragma mark 路由push方法
-(void)routerWithURL:(NSString *)url complete:(void (^)(BOOL))block{
    [self routerWithURL:url params:nil complete:block];
}

-(void)routerWithURL:(NSString *)url params:(NSDictionary *)params complete:(void (^)(BOOL))block{
    //去除掉首尾的空白字符和换行字符
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
        //url,跳转Safari页面
        [self toSysWebWithUrl:url];
        return;
    }
    
    SASRouterModel *routerModel = [self sas_modelWithURL:url];
    if (params) {
        NSDictionary *modelParams = routerModel.params;
        //参数合并
        if (params && [params isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:modelParams];
            [dic addEntriesFromDictionary:params];
            routerModel.params = dic;
        }
    }
    [self routerWithModel:routerModel complete:block];
}

-(void)routerWithRouterName:(NSString *)name complete:(void (^)(BOOL))block{
    [self routerWithRouterName:name params:nil complete:block];
}

-(void)routerWithRouterName:(NSString *)name params:(NSDictionary *)params complete:(void (^)(BOOL))block{
    NSString *url = [self sas_urlWithRouterName:name];
    if (!url || url.length == 0) {
        NSLog(@"路由异常：通过类名[%@]找不到映射的url",name);
        [self sas_router:nil complete:block];
        return;
    }
    [self routerWithURL:url params:params complete:block];
}

#pragma mark 路由pop方法
-(void)popRouter{
    [self popRouterWithParams:nil animated:YES];
}

-(void)popRouterAnimated:(BOOL)animated{
    [self popRouterWithParams:nil animated:animated];
}

///路由返回上一级并回传参数给上一级页面
- (void)popRouterWithParams:(NSDictionary *)params {
    [self popRouterWithParams:params animated:YES];
}

-(void)popRouterWithParams:(NSDictionary *)params animated:(BOOL)animated{
    UIViewController *lastVC = [[self class] topViewController];
    UINavigationController *nv = lastVC.navigationController;
    if (lastVC.presentingViewController && lastVC.navigationController.viewControllers.count == 1) {
        [lastVC dismissViewControllerAnimated:animated completion:^{
            if (params) {
                [self sas_tryLastPageResult:params];
            }
        }];
    }else{
        if ([nv isKindOfClass:[XCNavigationController class]]) {
            XCNavigationController *nav = (XCNavigationController *)nv;
            [nav popViewControllerAnimated:animated complete:^(BOOL finished) {
                if (params) {
                    [self sas_tryLastPageResult:params];
                }
            }];
        }else{
            [nv popViewControllerAnimated:animated];
        }
    }
}

//返回到第N级页面
-(void)popRouterToIndex:(NSInteger)index{
    [self popRouterToIndex:index params:nil animated:YES];
}

-(void)popRouterToIndex:(NSInteger)index animated:(BOOL)animated{
    [self popRouterToIndex:index params:nil animated:animated];
}

-(void)popRouterToIndex:(NSInteger)index params:(NSDictionary *)params{
    [self popRouterToIndex:index params:params animated:YES];
}

-(void)popRouterToIndex:(NSInteger)index params:(NSDictionary *)params animated:(BOOL)animated{
    if (index < 0) {
        NSAssert(NO, @"路由异常：index小于0");
        return;
    }
    
    UIViewController *lastVC = [[self class] topViewController];
    UINavigationController *nv = lastVC.navigationController;
    NSArray *vcArray = [nv.viewControllers mutableCopy];
    if (index >= vcArray.count) {
        NSAssert(NO, @"路由异常：index超出范围");
        return;
    }
    if (index == vcArray.count - 1 || vcArray.count <= 1) {
        //最后一个下标或者是vc数组里只有一个控制器时
        if (lastVC.presentingViewController) {
            [lastVC dismissViewControllerAnimated:animated completion:^{
                if (params) {
                    [self sas_tryLastPageResult:params];
                }
            }];
        }else{
            NSAssert(NO, @"路由异常：index是当前控制器的下标");
        }
        return;
    }
    
    id targetVC = [vcArray objectAtIndex:index];
    if (!targetVC || ![targetVC isKindOfClass:[UIViewController class]]) {
        return;
    }

    if ([nv isKindOfClass:[XCNavigationController class]]) {
        XCNavigationController *nav = (XCNavigationController *)nv;
        [nav popToViewController:targetVC animated:animated complete:^(BOOL finished) {
            if (params && finished) {
                [self sas_tryLastPageResult:params];
            }
        }];
    }else{
        [nv popToViewController:targetVC animated:animated];
    }
}

//返回到指定名称的控制器
-(void)popRouterWithTargetVCName:(NSString *)targetVCName{
    [self popRouterWithTargetVCName:targetVCName params:nil animated:YES];
}

-(void)popRouterWithTargetVCName:(NSString *)targetVCName animated:(BOOL)animated{
    [self popRouterWithTargetVCName:targetVCName params:nil animated:animated];
}

- (void)popRouterWithTargetVCName:(NSString *)targetVCName params:(NSDictionary *)params{
    [self popRouterWithTargetVCName:targetVCName params:params animated:YES];
}

-(void)popRouterWithTargetVCName:(NSString *)targetVCName params:(NSDictionary *)params animated:(BOOL)animated{
    [self popRouterWithTargetVCName:targetVCName params:params animated:animated sort:SASRouterTargetVCNameSortType_asc];
}

-(void)popRouterWithTargetVCName:(NSString *)targetVCName params:(NSDictionary *)params animated:(BOOL)animated sort:(SASRouterTargetVCNameSortType)sort{
    if (targetVCName.length == 0 || ![targetVCName isKindOfClass:[NSString class]]) {
        NSAssert(NO, @"路由异常：指定pop的控制器名称有误，请检查");
        return;
    }
    
    UIViewController *lastVC = [[self class] topViewController];
    UINavigationController *nv = lastVC.navigationController;
    NSArray *vcArray = [nv.viewControllers mutableCopy];
    
    if (sort == SASRouterTargetVCNameSortType_desc) {
        //降序
        vcArray = [[vcArray reverseObjectEnumerator] allObjects];
    }
    
    for (UIViewController *itemVC in vcArray) {
        id tempVC = itemVC;
        if (![tempVC isKindOfClass:[UIViewController class]]) {
            return;
        }
        if ([NSStringFromClass([tempVC class]) isEqualToString:targetVCName]) {
            if ([nv isKindOfClass:[XCNavigationController class]]) {
                XCNavigationController *nav = (XCNavigationController *)nv;
                [nav popToViewController:tempVC animated:animated complete:^(BOOL finished) {
                    if (params && finished) {
                        [self sas_tryLastPageResult:params];
                    }
                }];
            }else{
                [nv popToViewController:tempVC animated:animated];
            }
            return;
        }
    }
}

//pop的时候向上一个页面传递数据
-(void)sas_tryLastPageResult:(NSDictionary *)params {
    //这里已经是pop或者dismiss之后的最顶层控制器啦
    UIViewController *lastVC = [[self class] topViewController];
    SEL sel = NSSelectorFromString(@"onNextPopResult:");
    if ([lastVC respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [lastVC performSelector:sel withObject:params];
#pragma clang diagnostic pop
    }
}

#pragma mark 切换tabbar
- (void)sas_switchTab:(NSUInteger)index {
    UIViewController *topVC = [[self class] topViewController];
    UITabBarController *tabVC = [topVC tabBarController];
    if (index >= tabVC.childViewControllers.count) {
        NSAssert(NO, @"路由异常：tabbar index超出了范围");
        return;
    }
    
    [tabVC setSelectedIndex:index];
    [topVC.navigationController popToRootViewControllerAnimated:YES];
    topVC.hidesBottomBarWhenPushed = NO;
}

#pragma mark 跳转safari页面
-(void)toSysWebWithUrl:(NSString *)URL{
    SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:URL]];
    [[[self class] topViewController] presentViewController:safariVc animated:YES completion:nil];
}

#pragma mark 校验model里的参数是否合法
- (void)routerWithModel:(SASRouterModel *)model complete:(void(^_Nullable)(BOOL finished))block{
    BOOL isValid = [self sas_checkParamsWithModel:model];
    if (!isValid) {
        NSLog(@"路由异常：model参数不合法，请检查参数");
        return;
    }
    
    [self sas_router:model complete:block];
}

#pragma mark 进行路由跳转
- (void)sas_router:(SASRouterModel *)model complete:(void (^)(BOOL))block {
    
    if ([model.targetURLComponents.path isEqualToString:@"/tabbar"]) {
        NSUInteger index = 0;
        if (model.params && model.params.count > 0) {
            NSString *indexStr = [model.params objectForKey:@"index"];
            if (indexStr) {
                index = [indexStr integerValue];
            }else{
                NSAssert(NO, @"路由异常：跳转tabbar但是没有传index");
                return;
            }
        }
        [self sas_switchTab:index];
        return;
    }
    
    // 1. 得到vc类
    UIViewController *vc = [self sas_pageWithModule:model];
    
    if (!vc) {
        return;
    }
    //2. 跳转
    [self sas_jumpPage:model.jumpType viewController:vc complete:block];
}

- (void)sas_jumpPage:(SASRouterJumpType)type viewController:(UIViewController *)vc complete:(void (^)(BOOL))block {
    UIViewController *topVC = [[self class] topViewController];
    UINavigationController *nv = topVC.navigationController;
    switch (type) {
        case SASRouterJumpType_push:
        {
            if (!nv) {
                NSLog(@"路由异常：push到%@页时,调用页面必须要有导航栏",vc);
                return;
            }
            if ([nv isKindOfClass:[XCNavigationController class]]) {
                XCNavigationController *nav = (XCNavigationController *)nv;
                [nav pushViewController:vc animated:YES complete:block];
            }else{
                [nv pushViewController:vc animated:YES];
            }
        }
            break;
        case SASRouterJumpType_present:
        {
            Class class = NSClassFromString(@"XCNavigationController");
            if (!class) {
                class = [UINavigationController class];
            }
            
            UINavigationController *nav = [[class alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.navigationBar.barTintColor = [UIColor whiteColor];
            [topVC presentViewController:nav animated:YES completion:^{
                if (block) {
                    block(YES);
                }
            }];
        }
            break;
        default:
        {
            if (!nv) {
                NSLog(@"路由异常：push到%@页时,调用页面必须要有导航栏",vc);
                return;
            }
            if ([nv isKindOfClass:[XCNavigationController class]]) {
                XCNavigationController *nav = (XCNavigationController *)nv;
                [nav pushViewController:vc animated:YES complete:block];
            }else{
                [nv pushViewController:vc animated:YES];
            }
        }
            break;
    }
}

//获取页面控制器
- (UIViewController *)sas_pageWithModule:(SASRouterModel *)model {
    UIViewController *vc = nil;
    // 1. 为空处理
    if (!model || model.url.length == 0) {
        NSLog(@"路由异常：路由实体类或者URL为空");
        return self.notFoundViewController;
    }
    
    // 2. 判断原生类是否已集成
    NSString *className = model.className;
    Class class = NSClassFromString(className);
    if (!class) {
        NSLog(@"路由异常：找不到[%@]需要跳转的原生类, 请检查类名是否正确",className);
        return nil;
    }
    
    // 创建vc，并为vc赋值参数，在vc里通过paramDic获取
    vc = [[class alloc] init];
    SEL sel = NSSelectorFromString(@"setRouterParameter:");
    BOOL isConforms = [vc respondsToSelector:sel];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:model.params];
    if (params.count > 0 && isConforms) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //消警告
        [vc performSelector:sel withObject:params];
#pragma clang diagnostic pop
    }
    
    return vc;
}

#pragma mark 对url进行解析
//兼容参数中的中文
-(NSString *)encodeString:(NSString *)uncodeString{
    if (uncodeString.length == 0) {
            return nil;
        }
        // 先尝试使用原始字符串创建url
        NSURL *url = [NSURL URLWithString:uncodeString];
        if (url == nil) {
            // 如果url为nil，说明uncodeString中含有中文或者是url无法识别的特殊字符串，则调用下面的方法进行转码
            NSString *decodeString = [uncodeString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            url = [NSURL URLWithString:decodeString.length >0 ? decodeString : uncodeString];
        }
        return url.absoluteString;
}

///对url进行解析，转成路由模型model
- (SASRouterModel *)sas_modelWithURL:(NSString *)targetUrl {
   __block SASRouterModel *model = nil;
    
    if (!targetUrl || targetUrl.length == 0) {
        NSLog(@"路由异常：url为空...");
        return model;
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:[self encodeString:targetUrl]];
    if([components.scheme hasPrefix:@"http"] || [components.scheme hasPrefix:@"https"]) {
        return model;
    }
    
    BOOL isValid = [self sas_checkURL:components];
    if (!isValid) {
        return model;
    }
    
    NSString *moduleName = [self sas_moduleNameWithURLPath:components.path];
    if (!moduleName || moduleName.length == 0) {
        NSLog(@"路由异常：[%@]模块名为空",targetUrl);
        return model;
    }
    
    NSDictionary *routers = self.routes;
    if (!routers) {
        NSLog(@"路由异常：配置文件为空，请检查路由配置文件");
        return model;
    }
    
    //获取配置文件中对应模块名下的所有url链接
    NSArray *array = [routers objectForKey:moduleName];
    if (!array || array.count == 0) {
        NSLog(@"路由异常：获取 [%@] 下的对应路由配置信息为空",moduleName);
        return model;
    }
    
    __weak __typeof(self)weakSelf = self;
    [array enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __typeof(weakSelf)self = weakSelf;
        SASRouterModel *tempModel = [[SASRouterModel alloc] initWithDic:item];
        tempModel.targetURLComponents = components;
        
        //路由文件里的url
        NSString *modelURL = [self sas_filterUrlParamsAndScheme:tempModel.url];
        //外部使用路由时，传进来的url
        NSString *targetURL = [self sas_filterUrlParamsAndScheme:targetUrl];
        if ([modelURL isEqualToString:targetURL]) {
            //两者一致
            tempModel.targetURL = targetUrl;
            model = tempModel;
            // 参数处理
            NSDictionary *dic = [self sas_handlerParams:components];
            if(dic && dic.count > 0) {
                tempModel.params = dic;
            }
            *stop = YES;
        }
    }];
    
    return model;
}

/**
 根据类名去映射文件中获取url
 
 @param name 路由名
 @return url
 */
- (NSString *)sas_urlWithRouterName:(NSString *)name {
    NSString *url = nil;
    if(!name || name.length == 0) {
        return url;
    }
    
    NSDictionary *nameDic = self.routerNameDic;
    if(!nameDic) {
        NSLog(@"路由配置文件格式是否正常或者配置文件丢失");
        return url;
    }
    url = [nameDic objectForKey:name];
    
    return url;
}

/**
 根据url path 获取一级目录, 也就是模块名
 
 @param path url path
 @return 模块名
 */
- (NSString *)sas_moduleNameWithURLPath:(NSString *)path {
    NSString *moduleName = nil;
    if (!path || path.length == 0) {
        NSLog(@"警告：一级目录为空");
        return moduleName;
    }
    
    NSArray *pathArray = [path componentsSeparatedByString:@"/"];
    if(pathArray.count > 1) {
        moduleName = [pathArray objectAtIndex:1];
    }
    return moduleName;
}

/**
 校验url是否合法
 校验规则:
    1、前缀必须sas开头
    2、必须要有host
    3、必须要有path
 
 @param urlComponents 路由url
 @return YES-合法 NO-非法
 */
- (BOOL)sas_checkURL:(NSURLComponents *)urlComponents{
    if (![urlComponents.scheme hasPrefix:kSASSheme]) {
        NSLog(@"前缀非sas开头，非法路径");
        return NO;
    }
    
    if (!urlComponents.host || urlComponents.host.length == 0) {
        NSLog(@"没有host，非法路径");
        return NO;
    }
    
    if (!urlComponents.path || urlComponents.path.length == 0) {
        NSLog(@"没有一级、二级路径，非法路径");
        return NO;
    }
    return YES;
}

/**
 过滤URL请求参数，用于判断路由文件的url和外部传入的url是否一致
 
 @param url 当前URL
 @return 返回过滤掉参数的URL
 */
- (NSString *)sas_filterUrlParamsAndScheme:(NSString *)url {
    if(!url || url.length == 0) {
        return nil;
    }
    
    // 过滤参数
    NSArray *array = [url componentsSeparatedByString:@"?"];
    NSString *targetURL = [array firstObject];
    // 过滤scheme码
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:targetURL];
    NSString *scheme = urlComponents.scheme;
    
    NSRange range = [targetURL rangeOfString:scheme];
    if (range.location == NSNotFound) {
        return targetURL;
    }
    
    // 这里+3是把 :// 一起加上了
    NSInteger index = range.location + range.length + 3;
    if (targetURL.length > index) {
        targetURL = [targetURL substringFromIndex:index];
    }
    
    return targetURL;
}

/**
 url参数获取
 
 @param components url转换后的对象
 @return 请求参数
 */
- (NSDictionary *)sas_handlerParams:(NSURLComponents *)components {
    return [self getParamsByComponents:components];
}

- (NSDictionary *)getParamsByComponents:(NSURLComponents *)components {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:5];
    if(!components) {
        return dic;
    }
    NSArray<NSURLQueryItem *> *items = components.queryItems;
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = item.name;
        NSString *value = item.value;
        // 过滤页面跳转类型
        if([name isEqualToString:kJumpType]) {
            return;
        }
        if (!value) {
            value = @"";
        }
        [dic setObject:value forKey:name];
    }];
    return dic;
}

#pragma mark 校验model中的参数是否合法
- (BOOL)sas_checkParamsWithModel:(SASRouterModel *)model{
    
    __block BOOL isValid = YES;
    // 如果model为空, 直接返回验证成功
    if(!model) {
        return isValid;
    }
    
    NSString *url = model.url;
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    NSArray *items = components.queryItems;
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = item.name;
        BOOL hasRequireParameter = [name hasPrefix:@"*"];
        // 如果是必填参数, 则需要校验参数是否为*或者为空
        if (hasRequireParameter) {
            NSString *tempName = [name stringByReplacingOccurrencesOfString:@"*" withString:@""];
            NSString *value = [model.params objectForKey:tempName];
            if (![tempName isEqualToString:kJumpType]) {
                //jumpType有默认值，不参与这个判断
                if (value && ![value isKindOfClass:NSString.class]) {
                    //非字符串，只要不为nil，就验证通过
                    NSLog(@"路由异常：[%@]必填参数, 不是字符串", tempName);
                }else{
                    if (!value || value.length == 0 || [value isEqualToString:@"*"]) {
                        NSLog(@"路由异常：[%@]为必填参数, 不能为空或*", tempName);
                        isValid = NO;
                        *stop = YES;
                    }
                }
            }
        }
    }];
    
    return isValid;
}

#pragma mark 获取顶层控制器
+ (UIViewController*)topViewController{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark 懒加载
- (NSDictionary *)routerNameDic {
    if(!_routerNameDic) {
        _routerNameDic = [self sas_routerNames];
    }
    return _routerNameDic;
}

- (NSDictionary *)routes {
    if (!_routes) {
        _routes = [self sas_routerModules];
    }
    return _routes;
}

- (UIViewController *)notFoundViewController {
    if (!_notFoundViewController) {
        _notFoundViewController = [[SASRouteNotFoundViewController alloc] init];
    }
    return _notFoundViewController;
}

@end

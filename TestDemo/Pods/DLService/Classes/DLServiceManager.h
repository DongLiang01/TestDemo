//
//  DLServiceManager.h
//  DLRepoDemo
//
//  Created by 董良 on 2022/10/3.
//

#import <Foundation/Foundation.h>
#import "LTEatProtocol.h"
#import "EatProtocal.h"
#import "DLLoginProtocol.h"

#define DLServiceSectName "DLServices"

#define DLSECDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

//如果启动过程中，第一次调用是在A类中，就会在A类被load的时候，往Mach-O文件的第三部分的__DATA区域中创建一个section，名字就是DLServices，然后后面每次被调用的时候，都会将（servicename,impl）以下面的形式保存在刚才创建的section中，然后我们在创建DLServiceManager单例的时候，就可以从Mach-O文件的第三部分的__DATA中A类对应的区域找到这个section，取出保存的所有数据。
#define EXPORT_SERVICE_DL(servicename,impl) \
char * k##servicename##_service DLSECDATA(DLServices) = "{ \""#servicename"\" : \""#impl"\"}";

@interface DLServiceManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)registerService:(Protocol *)service implClass:(Class)implClass;

- (id)createService:(Protocol *)service;

@end

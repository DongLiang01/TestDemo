//
//  DLServiceManager.m
//  DLRepoDemo
//
//  Created by 董良 on 2022/10/3.
//

#import "DLServiceManager.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>

static DLServiceManager *single = nil;

NSArray<NSString *> *DLServiceReadConfiguration(char *sectionName,const struct mach_header *mhp){
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
    
    //根据section的name和类的首地址获取可执行文件Mach-O的第三部分区域的__DATA中对应section的数据
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    //memory只有在mhp首地址对的时候才能获取到
    unsigned long counter = size/sizeof(void*);
    for (int idx = 0; idx < counter; ++idx) {
        char *string = (char*)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if (str) {
            //形式就是保存的：{ "DLLoginProtocol" : "DLLoginService"}
            NSLog(@"取出来的：%@",str);
            [configs addObject:str];
        };
    }

    return configs;
}

//该方法会在对已存在的类都调一遍，mhp会传该类对应的ocjc文件在虚拟内存中的首地址和大小
static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    NSArray<NSString *> *services = DLServiceReadConfiguration(DLServiceSectName, mhp);
    //打印很多次
    //NSLog(@"测试执行时机");
    for (NSString *map in services) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {

                NSString *protocol = [json allKeys][0];
                NSString *clsName  = [json allValues][0];

                if (protocol && clsName && single) {
                    [single registerService:NSProtocolFromString(protocol) implClass:NSClassFromString(clsName)];
                }
            }
        }
    }

}

void initProphet(void) {
    //传入一个函数作为回调，新的类被load时会调用这个函数，已存在的类也都会调用一遍这个函数，这个函数有固定的格式要求，void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)，第一个参数就是类在该进程的虚拟内存中的初始地址，第二个参数对应类在虚拟内存中的偏移。
    _dyld_register_func_for_add_image(dyld_callback);
}

@interface DLServiceManager()

@property (nonatomic, strong) NSMutableDictionary *collection;

@end

@implementation DLServiceManager
{
    dispatch_semaphore_t _lock;
}

+ (instancetype)sharedManager{
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        single = [[self alloc] init];
        [single setup];
        initProphet(); //获取mach-o 里面已经注册的service
    });
    return single;
}

-(void)setup{
    self.collection = [NSMutableDictionary dictionaryWithCapacity:10];
    _lock = dispatch_semaphore_create(1);
}

- (void)safeCall:(void(^)(void))block {
    //加锁
    dispatch_semaphore_wait(_lock, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    block();
    dispatch_semaphore_signal(_lock);
}

- (BOOL)registerService:(Protocol *)service implClass:(Class)implClass {
    
    __block BOOL succ = NO;
    __weak typeof(self)weakself = self;
    
    NSString *serviceString = NSStringFromProtocol(service);
    NSString *impString = NSStringFromClass(implClass);
    
    if (!serviceString.length || !impString.length) {
        return NO;
    }
    
    [self safeCall:^{
        if (weakself.collection[serviceString]) {
            succ = NO;
        } else {
            [weakself.collection setObject:impString forKey:serviceString];
            succ = YES;
        }
    }];
    
    return succ;
}

-(id)createService:(Protocol *)service{
    __block NSObject *impInstanse = nil;
    __weak typeof(self)weakself = self;
    NSString *serviceString = NSStringFromProtocol(service);
    if (!serviceString.length) {
        return impInstanse;
    }
    [self safeCall:^{
        NSString *impClassString = weakself.collection[serviceString];
        if (impClassString.length) {
            Class cls = NSClassFromString(impClassString);
            impInstanse = [[cls alloc] init];
        }
        
    }];
    
    return impInstanse;
}

@end

//
//  SASRouterModel.m
//  RightBTC
//
//  Created by 董良 on 2022/9/14.
//  Copyright © 2022 LYX. All rights reserved.
//

#import "SASRouterModel.h"

@implementation SASRouterModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _url = [dic objectForKey:@"url"];
        _className = [dic objectForKey:@"iclass"];
    }
    return self;
}

-(void)setTargetURL:(NSString *)targetURL{
    _targetURL = targetURL;
    [self handlerParams:targetURL];
}

- (void)handlerParams:(NSString *)url {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURLComponents *components = self.targetURLComponents;
    if (!components) {
        components = [[NSURLComponents alloc] initWithString:url];
    }
    
    NSArray *items = components.queryItems;
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:5];
    __block NSInteger jumpType = 1;
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = item.name == nil ? @"" : item.name;
        NSString *value = item.value == nil ? @"" : item.value;
        if([name isEqualToString:kJumpType]) {
            jumpType = value.integerValue;
        }else{
            [tempDic setObject:value forKey:name];
        }
    }];
    
    self.jumpType = jumpType;
    if(tempDic) {
        self.params = tempDic;
    }
}

@end

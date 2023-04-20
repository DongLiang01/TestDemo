//
//  EatProtocal.h
//  sdk_Test
//
//  Created by 董良 on 2022/9/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EatProtocal <NSObject>

@optional

-(void)breakfastEat:(NSString *)str;
-(void)createAppWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END

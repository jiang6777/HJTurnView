//
//  PVTurnView.h
//  TurnView
//
//  Created by Power on 2018/9/4.
//  Copyright © 2018年 Power. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PVTurnView : UIView

@property (nonatomic, strong) UIView *contentBackgroundView;

//滑动停止之后是否需要归位
@property (nonatomic, assign) BOOL isGoHomeWhenScrollEnd;

@property (nonatomic, copy) void(^insideTurnViewClickedBlock)(NSInteger idx);

@property (nonatomic, copy) void(^insideTurnViewCallbackStringBlock)(NSString *string);

@property (nonatomic, copy) void(^turnViewScrollEndBlock)(NSInteger idx);

- (void)recievePanGesture:(UIPanGestureRecognizer *)panGesture;

@property (nonatomic, assign) BOOL enabled;

- (void)addTurnView:(NSArray *)contentArray;

/**
 根据起始数值、结束数值和区间大小生成圆盘视图
 @param startIndex 起始数值  例如 0~100   区间10，分10段
 @param endIndex 结束数值
 @param section 区间大小
 */
- (void)addTurnViewStartIndex:(NSInteger)startIndex
				 withEndIndex:(NSInteger)endIndex
			   withEndSection:(NSInteger)section;


/**
 隐藏内部视图
 
 @param hidden 是否隐藏
 */
- (void)hideInsideTurnView:(BOOL)hidden;


/**
 滑动定格外侧选项
 
 @param idx 索引
 */
- (void)scrollToIndex:(NSInteger)idx;

/**
 滑动定格到某一个值
 
 @param valule 定格到某一只值
 @param animation 是否需要动画
 */
- (void)scrollToValue:(NSInteger)valule animation:(BOOL)animation;

/**
 切换内侧选项
 
 @param idx 索引
 */
- (void)cutToIndex:(NSInteger)idx;

@end

//
//  PVTurnView.m
//  TurnView
//
//  Created by Power on 2018/9/4.
//  Copyright © 2018年 Power. All rights reserved.
//

#import "PVTurnView.h"
#define PVLongValue(value1,value2) (value1>value2?value1:value2)
#define PVShortValue(value1,value2) (value1>value2?value2:value1)
#define SYRealValuePortait(value) ((value)/375.0f*PVShortValue([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height))
#define DEGREE_TO_RADIAN(__ANGLE__) ((__ANGLE__) * M_PI/180.0)
#define TURNSPEED 0.2
@interface PVTurnView ()

@property (nonatomic, strong) UIView *insideCircleView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *outsideIndicatorArrawImageView;
@property (nonatomic, strong) UIView *insideIndicatorArrawImageView;
@property (nonatomic, strong) UIView *outsideCircleView;
@property (nonatomic, strong) NSMutableArray *turnContentArrays;
@property (nonatomic, strong) NSMutableArray *turnContentInsideArrays;
@property (nonatomic, strong) NSMutableArray *insideStringArrays;
@property (nonatomic, assign) NSInteger startIndexValue;
@property (nonatomic, assign) NSInteger endIndexValue;
@property (nonatomic, assign) NSInteger indexSection;

@property (nonatomic, assign) NSInteger cIndex;

//起始点
@property (nonatomic, assign) CGPoint startPoint;
//临界长度
@property (nonatomic, assign) CGFloat maxLength;
//临界速度
@property (nonatomic, assign) CGFloat maxSpeed;
//保存圆盘转动的角度
@property (nonatomic, assign) CGFloat cAngle;
//保存手指触摸屏幕上一次控制点
@property (nonatomic, assign) CGPoint lastPoint;
//总转动的弧度
@property (nonatomic, assign) CGFloat totalRadian;
//两个文字之间的弧度
@property (nonatomic, assign) CGFloat minRadian;
//一次拖拽的弧度
@property (nonatomic, assign) CGFloat miliRadian;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end

@implementation PVTurnView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
		self.turnContentArrays = [NSMutableArray array];
		self.turnContentInsideArrays = [NSMutableArray array];
		self.insideStringArrays = [NSMutableArray arrayWithObjects:@"EV",@"ISO", nil];
		[self _initViews];
		self.maxSpeed = 150;
		self.maxLength = frame.size.width/2.0;
		self.cAngle = 0;
		self.totalRadian = 0;
		self.minRadian = 0;
		self.isGoHomeWhenScrollEnd = YES;
	}
	return self;
}

- (void)_initViews
{
	self.layer.cornerRadius = self.frame.size.width/2;
	self.layer.masksToBounds = YES;
	self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SYRealValuePortait(240), SYRealValuePortait(240))];
	self.shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
	self.shadowView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	[self addSubview:self.shadowView];
	self.shadowView.layer.cornerRadius = self.shadowView.bounds.size.width/2;
	self.shadowView.layer.masksToBounds = YES;
	
	
	self.insideCircleView = [[UIView alloc] initWithFrame:CGRectMake(SYRealValuePortait(19.5), SYRealValuePortait(19.5), self.shadowView.bounds.size.height - SYRealValuePortait(39), self.shadowView.bounds.size.height - SYRealValuePortait(39))];
	self.insideCircleView.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor;
	self.insideCircleView.layer.borderWidth = 1.0;
	[self.shadowView addSubview:self.insideCircleView];
	self.insideCircleView.layer.cornerRadius = self.insideCircleView.bounds.size.width/2;
	
	self.outsideIndicatorArrawImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_turn_arraw.png"]];
	self.outsideIndicatorArrawImageView.frame = CGRectMake(0, (self.bounds.size.height/2 - 3.5), 7, 7);
	self.outsideIndicatorArrawImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.outsideIndicatorArrawImageView];
	
	self.contentBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
	self.contentBackgroundView.backgroundColor = [UIColor clearColor];
	[self addSubview:self.contentBackgroundView];
	self.contentBackgroundView.frame = self.bounds;
	self.contentBackgroundView.layer.cornerRadius = self.frame.size.width/2;
	self.contentBackgroundView.layer.masksToBounds = YES;
	self.layer.cornerRadius = self.frame.size.width/2;
	self.layer.masksToBounds = YES;
	
	self.outsideCircleView = [[UIView alloc] initWithFrame:CGRectMake(SYRealValuePortait(19.5), SYRealValuePortait(19.5), self.bounds.size.height - SYRealValuePortait(39), self.bounds.size.height - SYRealValuePortait(39))];
	self.outsideCircleView.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor;
	self.outsideCircleView.layer.borderWidth = 1.0;
	[self.contentBackgroundView addSubview:self.outsideCircleView];
	self.outsideCircleView.layer.cornerRadius = self.outsideCircleView.bounds.size.width/2;
	
	
	self.outsideIndicatorArrawImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_turn_arraw.png"]];
	self.outsideIndicatorArrawImageView.frame = CGRectMake(0, (self.bounds.size.height/2 - 3.5), 7, 7);
	self.outsideIndicatorArrawImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.outsideIndicatorArrawImageView];
	
	
	self.insideIndicatorArrawImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_turn_arraw.png"]];
	self.insideIndicatorArrawImageView.frame = CGRectMake(self.shadowView.frame.origin.x, (self.bounds.size.height/2 - 3.5), 7, 7);
	self.insideIndicatorArrawImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.insideIndicatorArrawImageView];
	
	[self addGesture];
	[self addInsideTurnView];
}

//添加滑动手势
- (void)addGesture
{
	self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
	[self addGestureRecognizer:self.pan];
}

- (void)recievePanGesture:(UIPanGestureRecognizer *)panGesture
{
	[self panAction:panGesture];
}

- (void)panAction:(UIPanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		self.startPoint = [gesture locationInView:gesture.view];
		self.lastPoint = self.startPoint;
		self.miliRadian = 0;
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
		CGPoint velocityPoint = [gesture velocityInView:gesture.view];
		CGPoint currentPoint = [gesture locationInView:gesture.view];
		CGFloat distance = currentPoint.y - self.lastPoint.y;
		self.lastPoint = currentPoint;
		CGFloat angle = 0.5;
		//1、判断滑动速度是否超过了临界数值
		if (fabs(velocityPoint.y) > self.maxSpeed) {
			angle = TURNSPEED*distance*2*360.0/self.maxSpeed;
			[self setRotate:angle isAnimated:YES];
		} else {
			angle = TURNSPEED*distance*360.0/self.maxLength;
			[self setRotate:angle isAnimated:YES];
		}
	} else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateEnded) {
		[self goHomeTurnView];
	}
}

- (void)addTurnView:(NSArray *)contentArray
{
	if (contentArray.count == 0) {
		return;
	}
	if (self.turnContentArrays.count > 0) {
		[self resetSelfSubviews];
	}
	self.minRadian = (2*M_PI)/contentArray.count;
	for (int i = 0; i < contentArray.count; i++) {
		UIButton *contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[contentBtn addTarget:self action:@selector(controlClicked:) forControlEvents:UIControlEventTouchUpInside];
		[contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[contentBtn setTitle:contentArray[i] forState:UIControlStateNormal];
		contentBtn.titleLabel.font = [UIFont systemFontOfSize:SYRealValuePortait(10)];
		[self.contentBackgroundView addSubview:contentBtn];
		[self.turnContentArrays addObject:contentBtn];
		
//		CGFloat angle = M_PI * 2 / contentArray.count * i;
		CGFloat radian = (2*M_PI/contentArray.count)*i-M_PI_2;
		NSLog(@"radian:%f",radian*(i + 1));
		contentBtn.frame = CGRectMake(0, 0, SYRealValuePortait(70), SYRealValuePortait(40));
		float radius = self.outsideCircleView.frame.size.width/2;
		contentBtn.center = CGPointMake(SYRealValuePortait(19.5) + radius + radius * sin(radian),SYRealValuePortait(19.5) + radius - radius*cos(radian));
//		contentBtn.transform = CGAffineTransformRotate(contentBtn.transform, angle);
	}
}

- (void)setEnabled:(BOOL)enabled
{
	_enabled = enabled;
	self.pan.enabled = enabled;
	if (enabled) {
		[self addGestureRecognizer:self.pan];
	} else {
		[self removeGestureRecognizer:self.pan];
	}
	for (UIButton *btn in self.turnContentArrays) {
		btn.enabled = enabled;
	}
}


- (void)addInsideTurnView
{
//	NSArray *contentArray = @[/];
	for (int i = 0; i < self.insideStringArrays.count; i++) {
		CGFloat radian = 7*M_PI/4-M_PI_4*i;
		UIButton *contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[contentBtn addTarget:self action:@selector(controlCutClicked:) forControlEvents:UIControlEventTouchUpInside];
		[contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[contentBtn setTitle:self.insideStringArrays[i] forState:UIControlStateNormal];
		contentBtn.titleLabel.font = [UIFont systemFontOfSize:10];
		[self addSubview:contentBtn];
		[self.turnContentInsideArrays addObject:contentBtn];
		if (i == 1) {
			contentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
		}
		float radius = self.insideCircleView.frame.size.width/2;
		contentBtn.frame = CGRectMake(0, 0, SYRealValuePortait(50), SYRealValuePortait(40));
		contentBtn.center = CGPointMake(self.shadowView.frame.origin.x + SYRealValuePortait(19.5) + radius + radius * sin(radian),self.shadowView.frame.origin.x + SYRealValuePortait(19.5) + radius - radius*cos(radian));
	}
}

- (void)controlCutClicked:(UIControl *)control
{
	[self cutToIndex:[self.turnContentInsideArrays indexOfObject:control]];
}

- (void)resetSelfSubviews
{
	for (int i = 0; i < self.turnContentArrays.count; i++) {
		UIButton *btn = [self.turnContentArrays objectAtIndex:i];
		[btn removeFromSuperview];
		btn = nil;
	}
	__weak PVTurnView *weakTurnView = self;
	[[self subviews] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		__strong PVTurnView *strongTurnView = weakTurnView;
		[(UIView*)obj removeFromSuperview];
		[strongTurnView.turnContentInsideArrays removeAllObjects];
		[strongTurnView.turnContentArrays removeAllObjects];
		strongTurnView.insideCircleView = nil;
		strongTurnView.contentBackgroundView = nil;
		strongTurnView.totalRadian = 0;
	}];
	[self _initViews];
}

- (void)controlClicked:(UIControl *)control
{
	NSInteger i = (self.turnContentArrays.count) - [self.turnContentArrays indexOfObject:control];
	self.cIndex = [self.turnContentArrays indexOfObject:control];
	if (self.turnViewScrollEndBlock) {
		self.turnViewScrollEndBlock(self.cIndex);
	}
	NSLog(@"cindex:%ld",self.cIndex);
	[self scrollToIndex:i];
}

- (void)setRotate:(CGFloat)degress isAnimated:(BOOL)isAnimated
{
	CGFloat rotate = DEGREE_TO_RADIAN(degress);
	self.miliRadian = self.miliRadian + rotate;
	self.totalRadian = self.totalRadian + rotate;
	CGAffineTransform transform = self.contentBackgroundView.transform;
	transform = CGAffineTransformRotate(transform, -rotate);
	if (isAnimated) {
		[UIView animateWithDuration:0.2 animations:^{
			self.contentBackgroundView.transform = transform;
			for (UIButton *btn in self.turnContentArrays) {
				btn.transform = CGAffineTransformRotate(btn.transform, rotate);
			}
		}];
	} else {
		self.contentBackgroundView.transform = transform;
	}
}

- (void)goHomeTurnView
{
	if (self.isGoHomeWhenScrollEnd) {
		NSInteger idx = fabs(self.totalRadian)/self.minRadian;
		CGFloat surplusRadian = fabs(self.totalRadian) - idx*self.minRadian;
		if (surplusRadian*2 > self.minRadian) {
			if (self.totalRadian > 0) {
				surplusRadian = (idx + 1)*self.minRadian-fabs(self.totalRadian);
			} else {
				surplusRadian = -((idx + 1)*self.minRadian-fabs(self.totalRadian));
			}
		} else {
			if (self.totalRadian > 0) {
				surplusRadian = -surplusRadian;
			}
		}
		self.totalRadian += surplusRadian;
		self.miliRadian += surplusRadian;
		CGAffineTransform transform = self.contentBackgroundView.transform;
		transform = CGAffineTransformRotate(transform, -surplusRadian);
		[UIView animateWithDuration:0.2 animations:^{
			self.contentBackgroundView.transform = transform;
			for (UIButton *btn in self.turnContentArrays) {
				btn.transform = CGAffineTransformRotate(btn.transform, (surplusRadian));
			}
		} completion:^(BOOL finished) {
//			NSInteger tIndex = self.totalRadian/M_PI;
//			CGFloat cRadian = self.totalRadian-tIndex*M_PI;
//			NSInteger index = self.cIndex + (NSInteger)(self.miliRadian/self.minRadian);
			NSInteger index = self.totalRadian/self.minRadian;
			if (labs(index) >= self.turnContentArrays.count) {
				if (index > 0) {
					index = labs(index)%self.turnContentArrays.count;
				} else {
					index = self.turnContentArrays.count - labs(index)%self.turnContentArrays.count;
				}
			}
			if (index < 0) {
				index = self.turnContentArrays.count + index;//self.turnContentArrays.count + self.cIndex;
			}
			self.cIndex = index;
			NSLog(@"cindex:%ld",index);
			if (self.turnViewScrollEndBlock) {
				self.turnViewScrollEndBlock(self.cIndex);
			}
		}];
	}
}

- (void)scrollToIndex:(NSInteger)idx
{
	CGFloat scrollRadian = idx*self.minRadian;
	[UIView animateWithDuration:0.3 animations:^{
		self.contentBackgroundView.transform = CGAffineTransformMakeRotation(scrollRadian);
		for (UIButton *btn in self.turnContentArrays) {
			btn.transform = CGAffineTransformMakeRotation(-scrollRadian);
		}
	} completion:^(BOOL finished) {
//		[self goHomeTurnView];
	}];
}

- (void)cutToIndex:(NSInteger)idx
{
	if (idx == 1) {
		return;
	}
	if (self.insideTurnViewClickedBlock) {
		self.insideTurnViewClickedBlock(idx);
	}
	if (self.insideTurnViewCallbackStringBlock) {
		self.insideTurnViewCallbackStringBlock([self.insideStringArrays objectAtIndex:idx]);
	}
	[self.turnContentInsideArrays exchangeObjectAtIndex:idx withObjectAtIndex:1];
	[self.insideStringArrays exchangeObjectAtIndex:idx withObjectAtIndex:1];
	UIButton *centerContentBtn = [self.turnContentInsideArrays objectAtIndex:1];
	UIButton *currentContentBtn = [self.turnContentInsideArrays objectAtIndex:idx];
	CGRect centerRect = centerContentBtn.frame;
	centerContentBtn.frame = currentContentBtn.frame;
	currentContentBtn.frame = centerRect;
	//	NSInteger index = [];
	centerContentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
	currentContentBtn.titleLabel.font = [UIFont systemFontOfSize:10];
}

/**
 滑动定格到某一个值
 
 @param valule 定格到某一只值
 @param animation 是否需要动画
 */
- (void)scrollToValue:(NSInteger)valule animation:(BOOL)animation
{
	CGFloat scrollRadian = -((valule * 1.0)/(self.endIndexValue - self.startIndexValue))*M_PI*2;//idx*self.minRadian;
	if (animation) {
		[UIView animateWithDuration:0.3 animations:^{
			self.contentBackgroundView.transform = CGAffineTransformMakeRotation(scrollRadian);
			for (UIButton *btn in self.turnContentArrays) {
				btn.transform = CGAffineTransformMakeRotation(-scrollRadian);
			}
		} completion:^(BOOL finished) {
			
		}];
	} else {
		self.contentBackgroundView.transform = CGAffineTransformMakeRotation(scrollRadian);
		for (UIButton *btn in self.turnContentArrays) {
			btn.transform = CGAffineTransformMakeRotation(-scrollRadian);
		}
	}
}

/**
 隐藏内部视图
 
 @param hidden hidden
 */
- (void)hideInsideTurnView:(BOOL)hidden
{
	self.shadowView.hidden = hidden;
	self.insideIndicatorArrawImageView.hidden = hidden;
	self.insideCircleView.hidden= hidden;
	for (UIButton *btn in self.turnContentInsideArrays) {
		btn.hidden = hidden;
	}
}

/**
 根据起始数值、结束数值和区间大小生成圆盘视图
 @param startIndex 起始数值  例如 0~100   区间10，分10段
 @param endIndex 结束数值
 @param section 区间大小
 */
- (void)addTurnViewStartIndex:(NSInteger)startIndex
				 withEndIndex:(NSInteger)endIndex
			   withEndSection:(NSInteger)section
{
	if (startIndex > endIndex || section == 0) {
		return;
	}
	self.startIndexValue = startIndex;
	self.endIndexValue = endIndex;
	self.indexSection = section;
	if (self.turnContentArrays.count > 0) {
		[self resetSelfSubviews];
	}
	NSInteger sectionValue = (endIndex-startIndex)/section;
	self.minRadian = (2*M_PI)/section;
	for (int i = 0; i < section; i++) {
		NSString *title = [NSString stringWithFormat:@"%ld",startIndex + i*sectionValue];
		UIButton *contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[contentBtn addTarget:self action:@selector(controlClicked:) forControlEvents:UIControlEventTouchUpInside];
		[contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[contentBtn setTitle:title forState:UIControlStateNormal];
		contentBtn.titleLabel.font = [UIFont systemFontOfSize:SYRealValuePortait(10)];
		[self.contentBackgroundView addSubview:contentBtn];
		[self.turnContentArrays addObject:contentBtn];
		
		//		CGFloat angle = M_PI * 2 / contentArray.count * i;
		CGFloat radian = (2*M_PI/section)*i-M_PI_2;
		NSLog(@"radian:%f",radian*(i + 1));
		contentBtn.frame = CGRectMake(0, 0, SYRealValuePortait(70), SYRealValuePortait(40));
		float radius = self.outsideCircleView.frame.size.width/2;
		contentBtn.center = CGPointMake(SYRealValuePortait(19.5) + radius + radius * sin(radian),SYRealValuePortait(19.5) + radius - radius*cos(radian));
		//		contentBtn.transform = CGAffineTransformRotate(contentBtn.transform, angle);
	}
}

@end

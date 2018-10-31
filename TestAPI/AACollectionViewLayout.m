//
//  AACollectionViewLayout.m
//  TestAPI
//
//  Created by 乔杰 on 2018/10/30.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "AACollectionViewLayout.h"

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width

#define ScreenHeight    [UIScreen mainScreen].bounds.size.height

@interface AACollectionViewLayout ()

//collectionView区数
@property (nonatomic, assign) NSInteger sections;
//区头、区尾、单元格布局容器
@property (nonatomic, strong) NSMutableArray *attributesArr;
//按区（滚动行列数）记录当前布局最大位置（横向滚动：记录最大X坐标，竖向滚动：记录最大Y坐标）
@property (nonatomic, strong) NSMutableArray *maxPositionArr;
//横向滚动 记录下一区开始时的坐标
@property (nonatomic, assign) CGFloat maxPointX;
//竖向滚动 记录下一区开始时的坐标
@property (nonatomic, assign) CGFloat maxPointY;
//分区 记录滚动行列数
@property (nonatomic, strong) NSMutableArray *scrollCountArr;
//分区 记录区头高度
@property (nonatomic, strong) NSMutableArray *sectionHeaderHeightArr;
//分区 记录区尾高度
@property (nonatomic, strong) NSMutableArray *sectionFooterHeightArr;

@end

@implementation AACollectionViewLayout

- (instancetype)init {
    
    self = [super init];
    if (self) {
        //默认配置
        _sections = 1;
        _itemEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _scrollDirection = UICollectionViewScrollDirectionVertical;
        _attributesArr = [[NSMutableArray alloc] init];
        _maxPositionArr = [[NSMutableArray alloc] init];
        _scrollCountArr = [[NSMutableArray alloc] init];
        _sectionHeaderHeightArr = [[NSMutableArray alloc] init];
        _sectionFooterHeightArr = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - 初始化
- (void)loadDelegateData {
    [_attributesArr removeAllObjects];
    [_maxPositionArr removeAllObjects];
    [_scrollCountArr removeAllObjects];
    [_sectionHeaderHeightArr removeAllObjects];
    [_sectionFooterHeightArr removeAllObjects];
    
    //获取滚动方向
    if ([_delegate respondsToSelector: @selector(customLayoutScrollDirection:)]) {
        
        _scrollDirection = [_delegate customLayoutScrollDirection: self];
    }
    //获取区数
    _sections = [self.collectionView numberOfSections];
    
    //获取每一区滚动行列数 区头高度 区尾高度
    for (int i = 0; i < _sections; i ++) {
        if ([_delegate respondsToSelector: @selector(customLayout:numberOfScrollForSection:)]) {
            [_scrollCountArr addObject: [NSNumber numberWithInteger: [_delegate customLayout: self numberOfScrollForSection: i]]];
        }else {
            [_scrollCountArr addObject: [NSNumber numberWithInt: arc4random()%4 + 3]];
        }
        if ([_delegate respondsToSelector: @selector(customLayout:footViewHeightForSection:)]) {
            [_sectionHeaderHeightArr addObject: [NSString stringWithFormat: @"%f", [_delegate customLayout: self headViewHeightForSection: i]]];
        }else {
            [_sectionHeaderHeightArr addObject: @"0.1f"];
        }
        if ([_delegate respondsToSelector: @selector(customLayout:footViewHeightForSection:)]) {
            [_sectionFooterHeightArr addObject: [NSString stringWithFormat: @"%f", [_delegate customLayout: self footViewHeightForSection: i]]];
        }else {
            [_sectionFooterHeightArr addObject: @"0.1f"];
        }
    }
}

#pragma mark - 重写父类方法 布局

- (void)prepareLayout {
    
    [super prepareLayout];
    [self loadDelegateData];
    
    
    //初始化记录每一区每一滚动行(列)初始位置坐标 实际布局时会替换部分值
    for (int i = 0; i <_sections; i ++) {
        for (int j = 0; j < [_scrollCountArr[i] integerValue]; j ++) {
            CGFloat orgin = (i + 1) * [_sectionHeaderHeightArr[i] floatValue] + i * ([_sectionFooterHeightArr[i] floatValue] + _itemEdgeInsets.bottom);
            [_maxPositionArr addObject: [NSString stringWithFormat: @"%f", orgin]];
        }
    }

    CGFloat orginY = 0;
    NSInteger startPoint = 0;
    for (int i = 0; i <_sections; i ++) {
        //获取各区单元格间距
        if ([_delegate respondsToSelector: @selector(customLayout:itemEdgeInsetForSection:)]) {
            _itemEdgeInsets = [_delegate customLayout: self itemEdgeInsetForSection: i];
        }
        //获取该区单元格总数
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection: i];
        for (int j = 0; j < itemsCount; j ++) {
            if (j == 0) {
                //区头s布局
                UICollectionViewLayoutAttributes *attrHeader = [self layoutAttributesForSupplementaryViewOfKind: UICollectionElementKindSectionHeader atIndexPath: [NSIndexPath indexPathForRow: j inSection: i] orginY: orginY];
                [self.attributesArr addObject: attrHeader];
            }
            //单元格布局
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow: j inSection: i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath: indexPath startPoint: startPoint];
            [_attributesArr addObject: attr];
            
            //区尾布局
            if (j == itemsCount - 1) {
                if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
                    if (i < _sections - 1) {
                        orginY = self.maxPointY - [_sectionHeaderHeightArr[i + 1] floatValue];
                    }else {
                        orginY = self.maxPointY;
                    }
                }else {
                    if (i < _sections - 1) {
                        orginY = self.maxPointX - [_sectionHeaderHeightArr[i + 1] floatValue];
                    }else {
                        orginY = self.maxPointX;
                    }
                }
                UICollectionViewLayoutAttributes *attrFooter = [self layoutAttributesForSupplementaryViewOfKind: UICollectionElementKindSectionFooter atIndexPath: [NSIndexPath indexPathForRow: j inSection: i] orginY: orginY - [_sectionFooterHeightArr[i] floatValue]];
                [self.attributesArr addObject: attrFooter];
            }
        }
        //用计算出的该滚动行(列)最大坐标替换对应滚动数组中坐标
        startPoint += [_scrollCountArr[i] integerValue];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath startPoint:(NSInteger)startPoint {
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath: indexPath];

    NSInteger section = indexPath.section;
    NSInteger scrollCount = [_scrollCountArr[section] integerValue];
    if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
        //获取滚动高度
        CGFloat h = 0;
        if ([_delegate respondsToSelector: @selector(customLayout:heightForItemAtIndexPath:)]) {
            h = [_delegate customLayout:self heightForItemAtIndexPath:indexPath];
        }
        CGFloat w = (self.collectionView.frame.size.width - _itemEdgeInsets.left - _itemEdgeInsets.right - (scrollCount - 1) * _itemEdgeInsets.left) / scrollCount;
        //替换最大坐标
        NSInteger minYIndex = startPoint;
        int endPoint = (int)(startPoint + scrollCount);
        CGFloat minY = [[_maxPositionArr objectAtIndex: startPoint] floatValue];
        for (int i = (int)startPoint; i < endPoint; i ++) {
            CGFloat y = [_maxPositionArr[i] floatValue];
            if (y < minY) {
                minY = y;
                minYIndex = i;
            }
        }
        CGFloat x = _itemEdgeInsets.left + (w + _itemEdgeInsets.left) * (minYIndex - startPoint);
        CGFloat y = minY + _itemEdgeInsets.top;
        attr.frame = CGRectMake(x, y, w, h);
        [_maxPositionArr replaceObjectAtIndex: minYIndex withObject: [NSString stringWithFormat: @"%f", CGRectGetMaxY(attr.frame)]];
        //记录最大坐标并替换下一区区头位置
        if (indexPath.row == [self.collectionView numberOfItemsInSection: section] - 1) {
            if (section < _sections - 1) {
                self.maxPointY = [self getMaxValue] + [_sectionFooterHeightArr[section] floatValue] + _itemEdgeInsets.bottom + [_sectionHeaderHeightArr[section + 1] floatValue];
                for (int i = (int)endPoint; i < ((int)endPoint + [_scrollCountArr[section + 1] integerValue]); i ++) {
                    [_maxPositionArr replaceObjectAtIndex: i withObject: [NSString stringWithFormat: @"%f", self.maxPointY]];
                }
            }else {
                self.maxPointY = [self getMaxValue] + [_sectionFooterHeightArr[section] floatValue] + _itemEdgeInsets.bottom;
            }
        }
    }else {
        CGFloat h = (self.collectionView.frame.size.height - _itemEdgeInsets.top - _itemEdgeInsets.bottom - (scrollCount - 1) * _itemEdgeInsets.top) / scrollCount;
        //获取滚动宽度
        CGFloat w = 0;
        if ([_delegate respondsToSelector: @selector(customLayout:widthForItemAtIndexPath:)]) {
            w = [_delegate customLayout: self widthForItemAtIndexPath: indexPath];
        }
        //替换最大坐标
        NSInteger minXIndex = startPoint;
        int endPoint = (int)(startPoint + scrollCount);
        CGFloat minX = [[_maxPositionArr objectAtIndex: startPoint] floatValue];
        for (int i = (int)startPoint; i < endPoint; i ++) {
            CGFloat x = [_maxPositionArr[i] floatValue];
            if (x < minX) {
                minX = x;
                minXIndex = i;
            }
        }
        CGFloat x = minX + _itemEdgeInsets.left;
        CGFloat y = _itemEdgeInsets.top + (h + _itemEdgeInsets.top) * (minXIndex - startPoint);
        attr.frame = CGRectMake(x, y, w, h);
        [_maxPositionArr replaceObjectAtIndex: minXIndex withObject: [NSString stringWithFormat: @"%f", CGRectGetMaxX(attr.frame)]];
        //记录最大坐标并替换下一区区头位置
        if (indexPath.row == [self.collectionView numberOfItemsInSection: section] - 1) {
            if (section < _sections - 1) {
                self.maxPointX = [self getMaxValue] + [_sectionFooterHeightArr[section] floatValue] + _itemEdgeInsets.right + [_sectionHeaderHeightArr[section + 1] floatValue];
                for (int i = (int)endPoint; i < ((int)endPoint + [_scrollCountArr[section + 1] integerValue]); i ++) {
                    [_maxPositionArr replaceObjectAtIndex: i withObject: [NSString stringWithFormat: @"%f", self.maxPointX]];
                }
            }else {
                self.maxPointX = [self getMaxValue] + [_sectionFooterHeightArr[section] floatValue] + _itemEdgeInsets.right;
            }
        }
    }
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

    return self.attributesArr;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath orginY:(CGFloat)orginY {
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind: elementKind withIndexPath: indexPath];

    //获取对应区区头缩进
    UIEdgeInsets sectionHeadEdgeInset;
    if ([_delegate respondsToSelector: @selector(customLayout:edgeInsetForSectionHead:)]) {
        sectionHeadEdgeInset = [_delegate customLayout: self edgeInsetForSectionHead: indexPath.section];
    }else {
        sectionHeadEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    //获取对应区区头缩进
    UIEdgeInsets sectionFootEdgeInset;
    if ([_delegate respondsToSelector: @selector(customLayout:edgeInsetForSectionFoot:)]) {
        sectionFootEdgeInset = [_delegate customLayout: self edgeInsetForSectionFoot: indexPath.section];
    }else {
        sectionFootEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    if ([elementKind isEqualToString: UICollectionElementKindSectionHeader]) {
        attr.frame = CGRectMake(sectionHeadEdgeInset.left, orginY + sectionHeadEdgeInset.top, self.collectionView.frame.size.width - sectionHeadEdgeInset.left - sectionHeadEdgeInset.right, [_sectionHeaderHeightArr[indexPath.section] floatValue] - sectionHeadEdgeInset.top - sectionHeadEdgeInset.bottom);
    }else {
        attr.frame = CGRectMake(sectionFootEdgeInset.left, orginY + sectionFootEdgeInset.top, self.collectionView.frame.size.width - sectionFootEdgeInset.left - sectionFootEdgeInset.right, [_sectionFooterHeightArr[indexPath.section] floatValue] - sectionFootEdgeInset.top - sectionFootEdgeInset.bottom);
    }
    
    return attr;
}

- (CGSize)collectionViewContentSize {
    CGFloat maxValue = [self getMaxValue];
    if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGSizeMake(self.collectionView.frame.size.width, maxValue + _itemEdgeInsets.bottom + [[_sectionFooterHeightArr lastObject] floatValue]);
    } else {
        return CGSizeMake(maxValue + _itemEdgeInsets.right, self.collectionView.frame.size.height + [[_sectionFooterHeightArr lastObject] floatValue]);
    }
}

- (CGFloat)getMaxValue {
    CGFloat maxValue = [_maxPositionArr.firstObject floatValue];
    for (int i = 0; i < _maxPositionArr.count; i ++) {
        CGFloat value = [_maxPositionArr[i] floatValue];
        if (value > maxValue) {
            maxValue = value;
        }
    }
    return maxValue;
}

@end

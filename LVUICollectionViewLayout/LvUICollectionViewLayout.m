//
//  LvUICollectionViewLayout.m
//  CardTableView
//
//  Created by lvzhenhua on 16/7/28.
//  Copyright © 2016年 viper. All rights reserved.
//

#import "LvUICollectionViewLayout.h"

static const NSInteger LDefaultColumnCount = 2;
static const CGFloat LDefaultRowMargin = 5;
static const CGFloat LDefaultColumnMargin = 5;
static const UIEdgeInsets LDeafultEdgeInsets = {0,0,10,0};

@interface LvUICollectionViewLayout ()

@property (nonatomic ,strong) NSMutableArray *attsArray;
@property (nonatomic ,strong) NSMutableArray *columnHeights;

/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;
- (CGFloat)columnMargin;
- (CGFloat)rowMargin;
- (CGFloat)columncount;
- (UIEdgeInsets)edgeInsets;
@end

@implementation LvUICollectionViewLayout

#pragma mark --getter
- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInLayout:)]) {
       return [self.delegate columnMarginInLayout:self];
    }else{
       return LDefaultColumnMargin;
    }
}

- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInLayout:)]) {
        return [self.delegate rowMarginInLayout:self];
    }else{
        return LDefaultRowMargin;
    }
}

- (CGFloat)columncount{
    if ([self.delegate respondsToSelector:@selector(columnCountInLayout:)]) {
        return [self.delegate columnCountInLayout:self];
    }else{
        return LDefaultColumnCount;
    }
}

- (UIEdgeInsets)edgeInsets{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInLayout:)]) {
        return [self.delegate edgeInsetsInLayout:self];
    }else{
        return LDeafultEdgeInsets;
    }
}
/**  存放每一列高度的数组  */
- (NSMutableArray *)columnHeights{
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}
/**  存放全部的layoutAttribute  */
- (NSMutableArray *)attsArray
{
    if (!_attsArray) {
        _attsArray = [NSMutableArray array];
    }
    return _attsArray;
}
/**
 *  初始化
 */
- (void)prepareLayout
{
    [super prepareLayout];
    //清楚之前计算的高度
    [self.columnHeights removeAllObjects];
    for (NSInteger i = 0; i < LDefaultColumnCount; i++) {
        [self.columnHeights addObject:@(self.edgeInsets.top + self.headerReferenceSize.height)];
    }
    //清楚之前的布局属性
    [self.attsArray removeAllObjects];
    //添加各个分区的属性
    //在这里得到对应的内容的高度
    if ([self.delegate respondsToSelector:@selector(flowLayoutRefreshAndLoadMoreData)]) {
        self.contentHeight = [self.delegate flowLayoutRefreshAndLoadMoreData];
    }
    //重新布局
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (int i = 0; i < sectionCount; i++) {
        //分区头
        UICollectionViewLayoutAttributes *sectionHeader = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        [self.attsArray addObject:sectionHeader];
        NSInteger count = [self.collectionView numberOfItemsInSection:i];
        //这个是添加分区对应的各个item的frame属性
        for (int j = 0; j < count; j ++) {
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
            [self.attsArray addObject:attr];
        }
        //分区尾
        UICollectionViewLayoutAttributes *sectionFooter = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        [self.attsArray addObject:sectionFooter];
    }
}

/**
 *  决定cell的排布
 *
 *  @param rect 位置布局
 *
 *  @return 返回布局数组
 */

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    //设置布局属性的frame
    CGFloat itemW = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right - self.columnMargin*(self.columncount-1))/self.columncount;
    CGFloat itemH = [self.delegate collectionViewLayout:self heightForItemAtIndexPath:indexPath itemWidth:itemW];
    //初始化
    NSInteger minIndex = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (int i = 0; i < self.columncount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            minIndex = i;
        }
    }
    CGFloat itemX = self.edgeInsets.left+minIndex*(itemW+self.columnMargin);
    CGFloat itemY = minColumnHeight;
    if (itemY != self.edgeInsets.top) {
        itemY = minColumnHeight + self.rowMargin;
    }
    attrs.frame = CGRectMake(itemX, itemY, itemW, itemH);
    //更新最短的那列的高度
    self.columnHeights[minIndex] = @(CGRectGetMaxY(attrs.frame));
    CGFloat columnHeight = [self.columnHeights[minIndex]doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    return attrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *atts = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        CGSize size = CGSizeZero;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            size = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
        }
        //
        CGFloat x = 0;
        //需要计算对应的高度
       // CGFloat y = self.edgeInsets.top;
        __block NSUInteger index = 0;
        __block CGFloat maxHeight = [self.columnHeights[0] doubleValue];
        
        //循环对应的最高的那个
        [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber * sectionHeight, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat height = [sectionHeight doubleValue];
                if (maxHeight < height) {
                    maxHeight = height;
                    index = idx;
            }
        }];
        //得到对应的这个数据
        atts.frame = CGRectMake(x, maxHeight, size.width, size.height);
        //所有的列更新对应的高度
        CGFloat maxContentHeight = CGRectGetMaxY(atts.frame);
        [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber * sectionHeight, NSUInteger idx, BOOL * _Nonnull stop) {
            self.columnHeights[idx] = @(maxContentHeight);
        }];
        return atts;
    }else {
        UICollectionViewLayoutAttributes *footerAtts = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
        CGSize size = CGSizeZero;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            size = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
        }
        CGFloat x = 0;
        __block NSUInteger index = 0;
        __block CGFloat maxHeight = [self.columnHeights[0] doubleValue];
        [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber *sectionHeight, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat height = [sectionHeight doubleValue];
            if (height > maxHeight) {
                maxHeight = height;
                index = idx;
            }
        }];
        //
        footerAtts.frame = CGRectMake(x, maxHeight, size.width, size.height);
        //更新最短的高度
        CGFloat maxContentHeight = CGRectGetMaxY(footerAtts.frame);
        [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber * sectionHeight, NSUInteger idx, BOOL * _Nonnull stop) {
            self.columnHeights[idx] = @(maxContentHeight);
        }];
        return footerAtts;
      }
}

/**
 *  返回collectionView的大小
 *
 *  @return CGSize
 */
- (CGSize)collectionViewContentSize
{
    CGFloat maxColumnHeight = [self.columnHeights[0]doubleValue];
    CGFloat index = 0;
    for (int i = 1; i < self.columncount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (maxColumnHeight < columnHeight) {
            maxColumnHeight = columnHeight;
            index = i;
        }
    }
    return CGSizeMake(0, maxColumnHeight+self.edgeInsets.bottom);
}



@end

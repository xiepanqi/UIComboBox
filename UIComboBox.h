//
//  UICombobox.h
//  UserCombobox
//
//  Created by 谢攀琪 on 15/5/8.
//  Copyright (c) 2015年 谢攀琪. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIComboboxType){
    UIComboboxTypeSimple    = 0,        // 只能编辑不能选择，自动补全
    UIComboboxTypeDropdown  = 1,        // 可编辑可选择，自动补全
    UIComboboxTypeDropList  = 2,        // 不能编辑可选择
};

@interface UIComboBox : UITextField <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
}
@property(nonatomic)float cellHeight;       // 行高度
@property(nonatomic)int listShowNum;        // 下拉列表显示数据的数目
@property(nonatomic)UIComboboxType type;    // 类型
@property(nonatomic)BOOL sort;              // 是否排序

-(void)hidePulldownList;                    // 隐藏下拉列表
-(void)showPulldownList;                    // 显示下拉列表

-(NSUInteger)addOption:(NSString*)string;   // 在最后添加选项
-(NSUInteger)insertOption:(NSString*)string index:(NSUInteger)index;  // 在指定位置插入选项
-(NSUInteger)insertArray:(NSArray*)array atIndex:(NSIndexSet*)index;
-(BOOL)removeOptionFromIndex:(NSUInteger)index;  // 删除指定位置选项
-(void)removeOptionFromString:(NSString*)string;    // 删除指定字符串
-(NSUInteger)clear;                         // 清空所有选项
-(NSUInteger)findIndexFromString:(NSString*)string; // 根据字符串查索引
-(NSString*)findeStringFromIndex:(NSUInteger)index; // 根据索引查字符串
-(void)select:(NSUInteger)index;          // 根据索引选择
-(NSUInteger)count;
@end

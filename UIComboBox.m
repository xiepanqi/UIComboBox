//
//  UICombobox.m
//  UserCombobox
//
//  Created by 谢攀琪 on 15/5/8.
//  Copyright (c) 2015年 谢攀琪. All rights reserved.
//

#import "UIComboBox.h"

@interface UIComboBox() {
    UITableView *pullDownList;
    UIButton    *pullDownButton;
    NSMutableArray     *data;
    NSArray     *sortedData;
}

- (void)configure;
- (void)configureList;
- (void)configureButton;

- (void)adjustListLayout;       // 调整下拉列表的大小和位置
@end

@implementation UIComboBox

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

-(void)configure {
    _type = UIComboboxTypeDropdown;  // 默认既可以下拉又可以编辑
    _cellHeight = self.bounds.size.height;
    _listShowNum = 5;
    _sort = NO;
    data = [[NSMutableArray alloc] init];
    sortedData = nil;
    [self configureList];
    [self configureButton];
    
    [super setDelegate:self];
}

#pragma mark - 属性方法
-(void)setType:(UIComboboxType)Type {
    _type = Type;
    if (_type == UIComboboxTypeSimple) {
        self.rightViewMode = UITextFieldViewModeNever;      // 隐藏右侧视图
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    else {
        self.rightViewMode = UITextFieldViewModeAlways;     // 显示右侧视图
        self.clearButtonMode = UITextFieldViewModeNever;
    }
}

-(void)setCellHeight:(float)cellHeight {
    _cellHeight = cellHeight;
    [self adjustListLayout];
}

-(void)setListShowNum:(int)listShowNum {
    _listShowNum = listShowNum;
    [self adjustListLayout];
}

-(void)setSort:(BOOL)sort {
    _sort = sort;
    if (_sort) {
        sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self adjustListLayout];
}

-(void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self adjustListLayout];
}

#pragma mark - 下拉列表
-(void)configureList {
    pullDownList = [[UITableView alloc] init];
    pullDownList.delegate = self;
    pullDownList.dataSource = self;
    pullDownList.showsVerticalScrollIndicator = NO;
    
    [self adjustListLayout];
}

-(void)hidePulldownList {
    pullDownButton.selected = NO;
    [pullDownList removeFromSuperview];
}

-(void)showPulldownList {
    pullDownButton.selected = YES;
    // 这里之所以不用隐藏而用移除是尽量避免对父视图对其子视图操作时产生的影响,并且在最上层显示
    [[self.window.subviews objectAtIndex:0] addSubview:pullDownList];
}

-(void)adjustListLayout {
    float x = self.frame.origin.x - 5; // 左侧15像素空白无法消除，只能左移了
    float y = self.frame.origin.y + self.bounds.size.height;
    float listWidth = self.bounds.size.width + 8;
    float listHeight = (self.listShowNum < data.count ? self.listShowNum : data.count) * _cellHeight;
    pullDownList.frame = CGRectMake(x, y, listWidth, listHeight);
}

#pragma mark - 列表代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listCell"];
    }
    if (_sort) {
        cell.textLabel.text = [sortedData objectAtIndex:[indexPath row]];
    }
    else {
        cell.textLabel.text = [data objectAtIndex:[indexPath row]];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [[UIColor grayColor] CGColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setText:cell.textLabel.text];
    if (self.type == UIComboboxTypeDropdown) {
        [self hidePulldownList];
    }
    else {
        [self resignFirstResponder];
    }
}

#pragma mark - 右侧按钮
-(void)configureButton {
    UIImage* upImage = [UIImage imageNamed:@"dropup"];
    UIImage* downImage = [UIImage imageNamed:@"dropdown"];
    
    pullDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 根据编辑框高度确定按钮大小
    int buttonSide = self.bounds.size.height - 4;
    pullDownButton.bounds = CGRectMake(0, 0, buttonSide, buttonSide);
    
    [pullDownButton setImage:downImage forState:UIControlStateNormal];
    [pullDownButton setImage:upImage forState:UIControlStateSelected];
    [pullDownButton addTarget:self action:@selector(clickPullDown:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightView = pullDownButton;                   // 把右侧视图设置成按钮
}

-(void)clickPullDown:(UIButton*)sender {
    if ( sender.selected ) {
        [self hidePulldownList];
    }
    else {
        [self showPulldownList];
        if (self.type != UIComboboxTypeDropdown) {
            [self becomeFirstResponder];
        }
    }
}

#pragma mark - 编辑框代理
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ( _type == UIComboboxTypeDropdown ) {
        if ( pullDownButton.selected ) {
            [self hidePulldownList];
        }
        else {
            [self showPulldownList];
        }
        return NO;
    }
    else {
        return YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showPulldownList];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self hidePulldownList];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *str;
    if (string.length == 0) {
        str = [NSMutableString stringWithFormat:@"%@", [textField.text substringToIndex:textField.text.length - 1]];
    }
    else {
        str = [NSMutableString stringWithFormat:@"%@%@", textField.text, string];
    }
    NSUInteger index = 0;
    for (NSString *listString in data) {
        if (listString.length >= str.length
            && [[listString substringToIndex:str.length] compare:str options:NSCaseInsensitiveSearch] == NSOrderedSame ) {
            break;
        }
        else {
            index++;
        }
    }
    if (index < data.count) {
        index = index + _listShowNum - 1;
        if (index >= data.count) {
            index = data.count - 1;
        }
        [pullDownList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    return YES;
}

#pragma mark - 选项列表数据操作
-(NSUInteger)addOption:(NSString *)string {
    NSUInteger index = [data indexOfObject:string];
    if (index == NSNotFound) {
        index = data.count;
        [data addObject:string];
        if (_sort) {
            sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        }
    }
    return index;
}

-(NSUInteger)insertOption:(NSString *)string index:(NSUInteger)index {
    NSUInteger oldIndex = [data indexOfObject:string];
    if (oldIndex == NSNotFound) {
        oldIndex = index;
        [data insertObject:string atIndex:index];
        if (_sort) {
            sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        }
    }
    if (data.count < _listShowNum) {
        [self adjustListLayout];
    }
    return oldIndex;
}

-(NSUInteger)insertArray:(NSArray *)array atIndex:(NSIndexSet*)index {
    [data insertObjects:array atIndexes:index];
    if (_sort) {
        sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    [self adjustListLayout];
    return data.count;
}

-(BOOL)removeOptionFromIndex:(NSUInteger)index {
    if (index < data.count) {
        [data removeObjectAtIndex:index];
        if (_sort) {
            sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        }
        return YES;
    }
    else {
        return NO;
    }
}

-(void)removeOptionFromString:(NSString *)string {
    [data removeObject:string];
    if (_sort) {
        sortedData = [data sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

-(NSUInteger)clear {
    NSUInteger count = data.count;
    [data removeAllObjects];
    return count;
}

-(NSString *)findeStringFromIndex:(NSUInteger)index {
    if (index < data.count) {
        if (_sort) {
            return [sortedData objectAtIndex:index];
        }
        else {
            return [data objectAtIndex:index];
        }
    }
    else {
        return nil;
    }
}

-(NSUInteger)findIndexFromString:(NSString *)string {
    if (_sort) {
        return [sortedData indexOfObject:string];
    }
    else {
        return [data indexOfObject:string];
    }
}

-(void)select:(NSUInteger)index {
    if (index < data.count) {
        if (_sort) {
            [self setText:[sortedData objectAtIndex:index]];
        }
        else {
            [self setText:[data objectAtIndex:index]];
        }
    }
}

-(NSUInteger)count {
    return data.count;
}
@end

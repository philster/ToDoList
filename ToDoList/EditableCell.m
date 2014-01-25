//
//  EditableCell.m
//  ToDoList
//
//  Created by Phil Wee on 1/25/14.
//  Copyright (c) 2014 Philster. All rights reserved.
//

#import "EditableCell.h"

@implementation EditableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

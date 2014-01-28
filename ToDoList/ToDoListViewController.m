//
//  ToDoListViewController.m
//  ToDoList
//
//  Created by Phil Wee on 1/25/14.
//  Copyright (c) 2014 Philster. All rights reserved.
//

#import "ToDoListViewController.h"
#import "EditableCell.h"
#import "ToDoItem.h"

@interface ToDoListViewController ()

@property (nonatomic, strong) NSMutableArray *toDoItems;
@property (nonatomic, strong) UIBarButtonItem *tempLeftButtonItem;
@property (nonatomic, strong) UIBarButtonItem *tempRightButtonItem;

@end

@implementation ToDoListViewController

- (NSMutableArray *)toDoItems
{
    if (!_toDoItems) _toDoItems = [[NSMutableArray alloc] init];
    return _toDoItems;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Load data from persistent storage
        [self.toDoItems addObjectsFromArray:[self loadData]];
        
        if (self.toDoItems.count < 1) {
            // Create dummy todo list
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Eat breakfast"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Go to the gym (yeah right)"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Pick up dry cleaning"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Multiline item Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Dismiss keyboard by touching background of UITableView
    // http://stackoverflow.com/questions/2321038/dismiss-keyboard-by-touching-background-of-uitableview
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    // Set title and navigation buttons
    self.title = @"To Do List";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    
    // Load custom UITableViewCell from nib
    UINib *customNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"MyEditableCell"];
}

#pragma mark - Dismiss keyboard

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.toDoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyEditableCell";
    EditableCell *cell = (EditableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ToDoItem *toDoItem = self.toDoItems[indexPath.row];
    cell.toDoItemCell.text = toDoItem.text;
    cell.toDoItemCell.tag = indexPath.row;
    cell.toDoItemCell.delegate = self;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self removeItemAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSObject *itemToMove = [self.toDoItems objectAtIndex:fromIndexPath.row];
    [self.toDoItems removeObjectAtIndex:fromIndexPath.row];
    [self.toDoItems insertObject:itemToMove atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // minimum cell height
    static CGFloat minHeight = 44;
    
    // Derive attributed text and width
    ToDoItem *item = self.toDoItems[indexPath.row];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:item.text];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width - 40;  // screen width less 20px margins
    
    // Reference: http://stackoverflow.com/questions/18368567/uitableviewcell-with-uitextview-height-in-ios-7
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return MAX(size.height, minHeight);
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Text view delegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
 
    [self scrollToCursorForTextView:textView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return !self.isEditing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Cache menu buttons
    self.tempLeftButtonItem = self.navigationItem.leftBarButtonItem;
    self.tempRightButtonItem = self.navigationItem.rightBarButtonItem;

    // Create Done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self scrollToCursorForTextView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Restore cached menu buttons
    self.navigationItem.leftBarButtonItem = self.tempLeftButtonItem;
    self.navigationItem.rightBarButtonItem = self.tempRightButtonItem;
    
    // Replace item
    ToDoItem *item = [[ToDoItem alloc] initWithText:textView.text];
    [self.toDoItems replaceObjectAtIndex:textView.tag withObject:item];
    
    // Save data to user defaults
    [self saveData:self.toDoItems];
}

#pragma mark - Private methods

- (void)addItem:sender
{
    // Create new item
    ToDoItem *item = [[ToDoItem alloc] init];
    [self.toDoItems insertObject:item atIndex:0];
    
    // Refresh table view
    [self.tableView reloadData];
    
    // Enter edit mode
    EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.toDoItemCell becomeFirstResponder];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    // Remove item
    [self.tableView beginUpdates];
    [self.toDoItems removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    // Refresh table view
    [self.tableView reloadData];
    
    // Save data to persistent storage
    [self saveData:self.toDoItems];
}

- (void)scrollToCursorForTextView:(UITextView *)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible:(CGRect)rect
{
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

- (NSArray *)loadData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *archiveArray = [userDefaults objectForKey:@"toDoItems"];
    
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:archiveArray.count];
    for (NSString *text in archiveArray) {
        ToDoItem *item = [[ToDoItem alloc] initWithText:text];
        [itemArray addObject:item];
    }
    
    return itemArray;
}

- (void)saveData:(NSArray *)items
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:items.count];
    for (ToDoItem *item in items) {
        [archiveArray addObject:item.text];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:archiveArray forKey:@"toDoItems"];
    [userDefaults synchronize];
}


@end

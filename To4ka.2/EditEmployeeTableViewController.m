//
//  EditEmployeeTableViewController.m
//  To4ka.2
//
//  Created by Air on 28.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import "EditEmployeeTableViewController.h"
#import "EmployeesTableViewController.h"
#include <QuartzCore/QuartzCore.h>


@import AddressBook;

@interface EditEmployeeTableViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation EditEmployeeTableViewController

@synthesize editEmployee;
@synthesize hideSecondPhoneSection;


-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self.datePicker setMaximumDate: [NSDate date]];
    
    if ([_employeeSecondPhoneNumber.text = editEmployee.employeeSecondPhoneNumber length] == 0){
        hideSecondPhoneSection = YES;
    }
    else{
        hideSecondPhoneSection = NO;
    };
    
    for (UITextField *anyTextField in self.arreyTextField) {
        anyTextField.delegate = self;
    }
    
    _employeeShop.enabled = NO;
    _employeeFirstName.enabled = NO;
    _employeeLastName.enabled = NO;
    _employeePhoneNumber.enabled = NO;
    _employeeSecondPhoneNumber.enabled = NO;
    _employeeEmail.enabled = NO;
    _employeeNoteView.editable = NO;
    _datePicker.userInteractionEnabled = NO;
    
    self.addSecondPhoneNumberButtone.hidden = YES;
    
    _employeeShop.borderStyle = UITextBorderStyleNone;
    _employeeFirstName.borderStyle = UITextBorderStyleNone;
    _employeeLastName.borderStyle = UITextBorderStyleNone;
    _employeePhoneNumber.borderStyle = UITextBorderStyleNone;
    _employeeSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
    _employeeEmail.borderStyle = UITextBorderStyleNone;
    
  
    _employeeShop.text = editEmployee.employeeShop;
    _employeeFirstName.text = editEmployee.employeeFirstName;
    _employeeLastName.text = editEmployee.employeeLastName;
    _employeePhoneNumber.text = editEmployee.employeePhoneNumber;
    _employeeSecondPhoneNumber.text = editEmployee.employeeSecondPhoneNumber;
    _employeeEmail.text = editEmployee.employeeEmail;
    _employeeNoteView.text = editEmployee.employeeNote;
    _datePicker.date = editEmployee.employeeDateOfBirth;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - AddressBook Button AddEmployeeAddressBook

-(void)cantAddContactAlert{
    
    UIAlertView *cantAddContactAlert = [[UIAlertView alloc]
                                        initWithTitle: @"Cannot Add Contact"
                                        message: @"You must give the app permission to add the contact first."
                                        delegate:nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
    [cantAddContactAlert show];
}

-(void)addToPhoneBook {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1 This checks to see if the user has either denied your app access to the Address Book in the past, or it is restricted because of parental controls. In this case, all you can do is inform the user that you can’t add the contact because the app does not have permission.
        
        [self cantAddContactAlert];
        //NSLog(@"Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2 This checks to see if the user has already given your app permission to use their Address Book. In this case, you are free to modify the Address Book however you want.
        [self createGroupAddressBook];
        [self addEmployeeToContacts];
        NSLog(@"Authorized");
    }
    else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3 This checks to see if the user hasn’t decided yet whether not to give permission to your app.
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4 executes only if the user denies permission when your app asks.
                [self cantAddContactAlert];
                // NSLog(@"Just denied");
                return;
            }
            //5 executes if the user gives permission for you to use the Address Book.
            NSLog(@"Just authorized");
        });
        NSLog(@"Not determined");
    }
}

#pragma mark -
#pragma mark - AddressBook Create Group Phone Book


-(void)createGroupAddressBook {
    
    NSString *newGroupName = @"To4ka";
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook){
        BOOL groupNameIsEqual = NO;
        
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)ABRecordCopyValue(group,
                                                                             kABGroupNameProperty);
                
                if ([groupName isEqualToString:newGroupName]) {
                    groupNameIsEqual = YES;
                    break;
                }
            }
        }
        CFRelease(allGroups);
        
        if (groupNameIsEqual) {
            NSLog(@"This Group in Address Book Already Exists");
        }
        else {
            ABRecordRef group = ABGroupCreate();
            if (!group){
                NSLog(@"Error Creating Group in Address Book");
                return;
            }
            
            CFErrorRef error = nil;
            BOOL couldSetGroupName = ABRecordSetValue(group,
                                                      kABGroupNameProperty,
                                                      (__bridge CFStringRef)newGroupName,
                                                      &error);
            if (couldSetGroupName){
                if (ABAddressBookAddRecord(addressBook, group, &error)){
                    NSLog(@"New Group in Address Book Added");
                    [self saveAddressBook:addressBook];
                } else {
                    NSLog(@"Unable Add New Group in Address Book");
                }
            }
            else {
                NSLog(@"Error Installing Name Group");
            }
        }
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Employee Info For Phone Book


-(void)addEmployeeToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook) {
        
        self.datePicker.timeZone = [NSTimeZone localTimeZone];
        self.datePicker.calendar = [NSCalendar currentCalendar];
        
        NSString *firstName = _employeeFirstName.text;
        NSString *lastName = _employeeLastName.text;
        NSString *phone = _employeePhoneNumber.text;
        NSString *shop = _employeeShop.text;
        NSString *note = _employeeNoteView.text;
        NSString *secondPhone = _employeeSecondPhoneNumber.text;
        NSString *email = _employeeEmail.text;
        NSDate *dayOfBirth = _datePicker.date;
        
        ABRecordRef person = ABPersonCreate();
        if (!person) {
            NSLog(@"Can Not Create Employee");
            return;
        }
        
        CFErrorRef error = nil;
        
        BOOL couldSetFirstName = ABRecordSetValue(person,
                                                  kABPersonFirstNameProperty,
                                                  (__bridge CFStringRef)firstName,
                                                  &error);
        BOOL couldSetLastName = ABRecordSetValue(person,
                                                 kABPersonLastNameProperty,
                                                 (__bridge CFStringRef)lastName,
                                                 &error);
        
        BOOL couldSetCompanyName = ABRecordSetValue(person,
                                                    kABPersonOrganizationProperty,
                                                    (__bridge CFStringRef) shop,
                                                    &error);
        BOOL couldSetNotes = ABRecordSetValue(person,
                                              kABPersonNoteProperty,
                                              (__bridge CFStringRef) note,
                                              &error);
        BOOL couldSetBirthday = ABRecordSetValue(person,
                                                 kABPersonBirthdayProperty,
                                                 (__bridge CFDateRef)dayOfBirth,
                                                 nil);
        
        ABMutableMultiValueRef emailSet = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel (emailSet,
                                      (__bridge CFStringRef) email,
                                      kABWorkLabel,
                                      NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailSet, nil);
        CFRelease(emailSet);
        
        ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)phone,
                                     kABPersonPhoneMainLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)secondPhone,
                                     kABPersonPhoneMobileLabel,
                                     NULL);
        
        BOOL couldSetPhoneNumber = ABRecordSetValue(person,
                                                    kABPersonPhoneProperty,
                                                    phones,
                                                    &error);
        CFRelease(phones);
        
        if (couldSetCompanyName && couldSetFirstName && couldSetLastName && couldSetPhoneNumber && couldSetNotes && emailSet && couldSetBirthday) {
            NSLog(@"Connection Whith Address Book");
        }
        
        if (ABAddressBookAddRecord(addressBook, person, &error)) {
            NSLog(@"Employee Added To Address Book");
        }
        
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id record in allContacts){
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                                ABRecordCopyCompositeName(person), 0) == kCFCompareEqualTo){
                //The contact already exists!
                UIAlertView *SameContactExistsAlert = [[UIAlertView alloc]
                                                       initWithTitle:@"Can't Save in Address Book"
                                                       message:[NSString stringWithFormat:@"There can be only one %@ %@ in your Address Book", _employeeFirstName.text, _employeeLastName.text]
                                                       delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
                [SameContactExistsAlert show];
                return;
            }
        }
        [self saveAddressBook:addressBook];
        
        //Add to Group
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)
                ABRecordCopyValue(group, kABGroupNameProperty);
                
                if ([groupName isEqualToString:@"To4ka"]) {
                    if (ABGroupAddMember(group, person, &error)) {
                        
                        NSLog(@"Employee Added To Group");
                    }
                    else {
                        NSLog(@"Failed! Employee Failed Add To Group");
                    }
                    break;
                }
            }
        }
        CFRelease(allGroups);
        [self saveGroupAddressBook:addressBook];
        //Adding In Group
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Save Method To Phone Book Group & Person


-(void)saveAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        if (ABAddressBookSave(addressBook, &error)){
            
            NSLog(@"Employee Saved To Address Book");
        }
        else {
            UIAlertView *cantDisAddContactAlert = [[UIAlertView alloc]
                                                   initWithTitle: @"Sorry"
                                                   message: @"Can Not Add Employee To Address Book"
                                                   delegate:nil
                                                   cancelButtonTitle: @"OK"
                                                   otherButtonTitles: nil];
            [cantDisAddContactAlert show];
        }
    }
}

-(void)saveGroupAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        
        if (ABAddressBookSave(addressBook, &error)){
            NSLog(@"Employee in Group Added To Address Book");
        }
        else {
            NSLog(@"Can Not Add Employee in Group To Address Book");
        }
    }
}

#pragma mark -
#pragma mark - Hiden Second Phone Number Section


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
    {
    if (section == 4 && hideSecondPhoneSection) {
        return 0;
    }
    else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 4 && hideSecondPhoneSection) {
        cell.hidden = YES;
        return 0;
    }
    else {
        cell.hidden = NO;
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - Button Add Second Phone Number Button


-(IBAction)addSecondPhoneNumber:(id)sender {
    
    hideSecondPhoneSection = NO;
    [self.tableView reloadData];
    [self.employeeSecondPhoneNumber becomeFirstResponder];
    self.addSecondPhoneNumberButtone.hidden = YES;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Email


-(BOOL)checkEmailTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *validation = [NSCharacterSet characterSetWithCharactersInString:@"?±~!#$%^,/|&*()<>=+{}][:;'\" \\"];
    NSArray * components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (([newString rangeOfString:@"@"].length) < 1) {
        self.atPresent = NO;
    }
    if ([newString length] < 2 && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([newString length] > 30) {
        return NO;
    }
    if (self.atPresent && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([string isEqualToString:@"@"]) {
        self.atPresent = YES;
    }
    textField.text = newString;
    return NO;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Phone


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL yesOrNot = TRUE;
    if ([textField isEqual:self.employeePhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.employeeSecondPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.employeeEmail]) {
        yesOrNot = [self checkEmailTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return yesOrNot;
}

#pragma mark -
#pragma mark - UITextFieldDelegate Phone Number


-(BOOL)checkPhoneTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    NSMutableString* resultString = [NSMutableString string];
    
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    static const int countryMaxLenght = 2;
    
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght + countryMaxLenght) {
        return NO;
    }
    
    NSInteger localNumberLenght = MIN([newString length], localNumberMaxLenght);
    
    if (localNumberLenght > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLenght];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    if ([newString length] > localNumberMaxLenght) {
        
        NSInteger areaCodeLenght = MIN((int)[newString length] - localNumberMaxLenght, areaCodeMaxLenght);
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLenght - areaCodeLenght, areaCodeLenght);
        NSString* area = [newString substringWithRange:areaRange];
        area = [NSString stringWithFormat:@"(%@) ", area];
        [resultString insertString:area atIndex:0];
        
    }
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght) {
        
        NSInteger countryCodeLenght = MIN((int)[newString length] - localNumberMaxLenght - areaCodeMaxLenght, countryMaxLenght);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLenght);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        [resultString insertString:countryCode atIndex:0];
    }
    textField.text = resultString;
    return NO;
}

#pragma mark -
#pragma mark - Return key


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.employeeShop]) {
        [self.employeeFirstName becomeFirstResponder];
    }
    if ([textField isEqual:self.employeeFirstName]) {
        [self.employeeLastName becomeFirstResponder];
    }
    if ([textField isEqual:self.employeeLastName]) {
        [self.employeePhoneNumber becomeFirstResponder];
    }
    if ((self.hideSecondPhoneSection == YES) &&
        ([textField isEqual:self.employeePhoneNumber])){
        [self.employeeEmail becomeFirstResponder];
    }
    else if ((self.hideSecondPhoneSection == NO) &&
             ([textField isEqual:self.employeePhoneNumber])){
        [self.employeeSecondPhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.employeeEmail]) {
        [self.employeeNoteView becomeFirstResponder];
    }
    if ([textField isEqual:self.employeeSecondPhoneNumber]) {
        [self.employeeEmail becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark - Check For Same Employee & PhoneNumber Length For AddressBook


-(void)checkEmployeePhoneNumber{
    
    if ([_employeePhoneNumber.text length] == 0) {
        NSLog(@"Empty ");
    }
    else {
        
    [self addToPhoneBook];
    }
}

-(NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

-(BOOL)uniqueEntityExistsWithEnityName {
    
    BOOL returnValue = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"employeeShop = [cd] %@ AND employeeFirstName = [cd] %@ AND employeeLastName = [cd] %@",_employeeShop.text, _employeeFirstName.text, _employeeLastName.text];
    
    NSSortDescriptor *employeeShop = [[NSSortDescriptor alloc] initWithKey:@"employeeShop" ascending:YES];
    
    [request setSortDescriptors: @[employeeShop]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"request = %@",predicate);
    
    if (!matches) {
        NSLog(@"Error: Couldn't execute fetch request %@", error);
        
    }
    else if([matches count] > 1) {
        
        NSString *existEmployee = [NSString stringWithFormat:@"Could Be Only One %@,%@ In %@ Shop", _employeeFirstName.text, _employeeLastName.text, _employeeShop.text];
        
        UIAlertView *exist = [[UIAlertView alloc]initWithTitle:@"Employee Exists in Your Records"
                                                       message:existEmployee
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [exist show];
        
        NSLog(@"Error: Have more than %lu records",
              (unsigned long)[matches count]);
        returnValue = YES;
    }
    else {

        NSLog(@"%lu object in record", (unsigned long)[matches count]);
        
        editEmployee.employeeShop = _employeeShop.text;
        editEmployee.employeeFirstName = _employeeFirstName.text;
        editEmployee.employeeLastName = _employeeLastName.text;
        editEmployee.employeePhoneNumber = _employeePhoneNumber.text;
        editEmployee.employeeSecondPhoneNumber = _employeeSecondPhoneNumber.text;
        editEmployee.employeeEmail = _employeeEmail.text;
        editEmployee.employeeDateOfBirth = _datePicker.date;
        editEmployee.employeeNote = _employeeNoteView.text;
        
        [super saveAndDissmiss];
        
        returnValue = YES;
    }
    return returnValue;
}

#pragma mark - 
#pragma mark - oldEmployeeDelete


-(void)oldEmployeeDelete{

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFStringRef nameRef = (__bridge CFStringRef)
 
    [NSString stringWithFormat:@"%@, %@",
     editEmployee.employeeFirstName,
     editEmployee.employeeLastName];
    
    NSLog(@"old - %@,%@,%@",editEmployee.employeeFirstName,
          editEmployee.employeeLastName,
          editEmployee.employeePhoneNumber);
    
    CFArrayRef  AllRecords_ = ABAddressBookCopyPeopleWithName(addressBook, nameRef);
    
    if (AllRecords_ != NULL){
        int count = CFArrayGetCount(AllRecords_);
        for (int i = 0; i < count; ++i)
        {
            ABRecordRef contact = CFArrayGetValueAtIndex(AllRecords_, i);
            ABAddressBookRemoveRecord(addressBook, contact, nil);
        }
    }
    ABAddressBookSave(addressBook, nil);
    CFRelease(addressBook);

}

#pragma mark -
#pragma mark - Cance And Save


-(IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
}

-(IBAction)editSave:(UIBarButtonItem *)sender {
    if ([_editSaveButton.title isEqualToString:@"Edit"]) {
        NSLog(@"Edit Button Has Been Pressed!");
        
        [self setTitle:@"Edit Employee"];
        
        _employeeShop.enabled = YES;
        _employeeFirstName.enabled = YES;
        _employeeLastName.enabled = YES;
        _employeePhoneNumber.enabled = YES;
        _employeeSecondPhoneNumber.enabled = YES;
        _employeeEmail.enabled = YES;
        _employeeNoteView.editable = YES;
        _datePicker.userInteractionEnabled = YES;
        
        if (!([_employeeSecondPhoneNumber.text = editEmployee.employeeSecondPhoneNumber length] == 0)){
            self.addSecondPhoneNumberButtone.hidden = YES;
        } else{
            self.addSecondPhoneNumberButtone.hidden = NO;
        };
        
        [self.tableView reloadData];
        
        _employeeShop.borderStyle = UITextBorderStyleRoundedRect;
        _employeeFirstName.borderStyle = UITextBorderStyleRoundedRect;
        _employeeLastName.borderStyle = UITextBorderStyleRoundedRect;
        _employeePhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _employeeSecondPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _employeeEmail.borderStyle = UITextBorderStyleRoundedRect;
        
        _editSaveButton.title = @"Save";
        
        [self textViewStyle];
    }
    else {
        
        _employeeShop.enabled = NO;
        _employeeFirstName.enabled = NO;
        _employeeLastName.enabled = NO;
        _employeePhoneNumber.enabled = NO;
        _employeeSecondPhoneNumber.enabled = NO;
        _employeeEmail.enabled = NO;
        _employeeNoteView.editable = NO;
        _datePicker.userInteractionEnabled = NO;
        
        _employeeShop.borderStyle = UITextBorderStyleNone;
        _employeeFirstName.borderStyle = UITextBorderStyleNone;
        _employeeLastName.borderStyle = UITextBorderStyleNone;
        _employeePhoneNumber.borderStyle = UITextBorderStyleNone;
        _employeeSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
        _employeeEmail.borderStyle = UITextBorderStyleNone;
        
        _editSaveButton.title = @"Edit";
        
        if ([_employeeShop.text length] == 0 || [_employeeFirstName.text length] == 0 || [_employeeLastName.text length] == 0)
        {
            UIAlertView *empty = [[UIAlertView alloc]initWithTitle:@"Fill Up The Form"
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            [empty show];
        }
        else {
            
            [self oldEmployeeDelete];
            [self uniqueEntityExistsWithEnityName];
            [self checkEmployeePhoneNumber];
        }
    }
}

#pragma mark -
#pragma mark - TextView Style


-(void)textViewStyle{
    
    [[self.employeeNoteView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.employeeNoteView layer] setBorderWidth:.4];
    [[self.employeeNoteView layer] setCornerRadius:8.0f];
}

@end
//testing...

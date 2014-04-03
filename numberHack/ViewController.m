//
//  ViewController.m
//  numberHack
//
//  Created by yury.mehov on 2/18/14.
//  Copyright (c) 2014 yury.mehov. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "ProgressViewManager.h"
#import "TTTAttributedLabel.h"


#define PERFORM_SELECTOR(selector_Name) [self performSelector:@selector(selector_Name) withObject:nil afterDelay:1];

#define startString @"ВВЕДИТЕ НОМЕР ДЛЯ ПОИСКА"
#define searchString @"Пользователь с номером \n%@ \nнайден. Для детального поиска кликните по картинке"

@interface ViewController ()
{
    NSString *phoneNumberSearch;
    IBOutlet UITextField *numberTextField;
    IBOutlet UILabel *infoLbl;
    UIWebView *web;
    BOOL first;
    IBOutlet UILabel *nameLbl;
    IBOutlet UIImageView *avaImage;
    IBOutlet UIButton *contactButton;
    IBOutlet UIButton *backButton;

    int counter;
    
    NSMutableArray *contactList;
    
    NSString *urlImage;
}



@end

@implementation ViewController


#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    infoLbl.alpha = 0.0f;
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    infoLbl.alpha = 1;
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:numberTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)];
    [cancel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,
                                    [UIFont fontWithName:@"Helvetica" size:16.0],UITextAttributeFont,nil] forState:UIControlStateNormal];
    UIBarButtonItem *ok = [[UIBarButtonItem alloc]initWithTitle:@"Готово" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    [ok setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,
                                [UIFont fontWithName:@"Helvetica" size:16.0],UITextAttributeFont,nil] forState:UIControlStateNormal];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           cancel,
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           ok,
                           nil];
    [numberToolbar sizeToFit];
    numberTextField.inputAccessoryView = numberToolbar;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)getAllContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
    
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
		NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
		//For username and surname
		ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
		
        CFStringRef firstName, lastName;
		firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
		[dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
		
		
		//For Phone number
		NSString* mobileLabel;
        
		for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
			mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
			if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
			{
				[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
			}
			else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
			{
				[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
				break ;
			}
            
        }
        [contactList addObject:dOfPerson];
        
	}
    NSLog(@"Contacts = %@",contactList);
}

-(void)cancelNumberPad{
    [numberTextField resignFirstResponder];
    numberTextField.text = @"";
}

-(void)doneWithNumberPad{
    NSString *numberFromTheKeyboard = numberTextField.text;
    phoneNumberSearch = numberFromTheKeyboard;
    NSString *regexString = @"^[+\\-\\d\\s\\(\\)]+$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    BOOL matches = [test evaluateWithObject:phoneNumberSearch];
    if(!matches)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Некорректный номер.Повторите попытку" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        phoneNumberSearch = @"";
    }
    else{
        [numberTextField resignFirstResponder];
        [self voiceNumber];
    }
}
- (IBAction)voiceNumber {
    if(!backButton.isHidden)
    {
        avaImage.image = nil;
        nameLbl.text = @"";
        infoLbl.text = startString;
        infoLbl.hidden = NO;
        numberTextField.hidden = NO;
        backButton.hidden = YES;
        contactButton.hidden = NO;
    }
    else{
        web = [[UIWebView alloc] initWithFrame:self.view.frame];
        web.delegate = self;
        web.alpha = 0.01;
        [self.view addSubview:web];
        
        [[ProgressViewManager sharedProgressViewManager] showWithTitle:@"Анализ facebook"];
        [web loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://m.facebook.com/login/identify"]]];
    }
    
}

- (void)viewDidLayoutSubviews{
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) // iOS 7 or above
        
    {
        CGFloat top = self.topLayoutGuide.length;
        
        if(web.frame.origin.y == 0){ // We only want to do this once.
            web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y + top, web.frame.size.width, web.frame.size.height - top);
        }
        
    }
}

-(void)closeWeb
{
    numberTextField.text = @"";
    [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
    self.view.userInteractionEnabled = YES;
    [web removeFromSuperview];
    first = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView != web)
        return;
    if(first)
    {
        if([webView.request.URL.absoluteString rangeOfString:@"m.vk.com/restore"].location== NSNotFound)
        {
            [self getImageFacebook];
        }
        else
        {
            [self getImageVK];
        }
        return;
    }
    first = YES;
    NSString *savedUsername = phoneNumberSearch;
    
    if (savedUsername.length != 0) {
        NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[type='text']\"); \
                                    for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value='%@\';}",savedUsername];
        
        NSLog(@"start");
        [webView stringByEvaluatingJavaScriptFromString: loadUsernameJS];
        NSLog(@"/start");
        
        if([webView.request.URL.absoluteString rangeOfString:@"m.vk.com/restore"].location== NSNotFound){
            loadUsernameJS = [NSString stringWithFormat:@"var button = document.querySelectorAll(\"button[id='did_submit']\"); \
                              for (var i = button.length >>> 0; i--;) { button[i].click();}"];
            [webView stringByEvaluatingJavaScriptFromString: loadUsernameJS];
            PERFORM_SELECTOR(getImageFacebook);
        }
        else
        {
            loadUsernameJS = [NSString stringWithFormat:@"var button = document.querySelectorAll(\"input[type='submit']\"); \
                              for (var i = button.length >>> 0; i--;) { button[i].click();}"];
            [webView stringByEvaluatingJavaScriptFromString: loadUsernameJS];
            PERFORM_SELECTOR(getImageVK)
        }
    }
}

-(void)searchByImage:(NSString *)url
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    WebViewController *controller = (WebViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"WebViewController"];
    controller.url = url;
    [self presentViewController:controller animated:YES completion:^{
        //some thing
    }];
}

-(void)getImageVK
{
    NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"img[class='ii_img']\"); \
                                for (var i = inputFields.length >>> 0; i--;) { inputFields[i].src}"];
    
    //autofill the form
    NSString *url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
    if(url.length >0)
    {
        avaImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        urlImage = url;
    }
    else
    {
        NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='captcha_sid']\"); \
                                    for (var i = inputFields.length >>> 0; i--;) { inputFields[i].type;}"];
        
        //autofill the form
        NSString *url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
        if(url.length !=0)
        {
            web.alpha = 1;
            self.view.userInteractionEnabled = YES;
            [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
            return;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Номер не найден.Приносим свои извинения за доставленные неудобства" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            numberTextField.text = @"";
            [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
            self.view.userInteractionEnabled = YES;
            [web removeFromSuperview];
            first = NO;
            counter = 0;
            return;
        }
        
    }
    loadUsernameJS = [NSString stringWithFormat:@"document.querySelectorAll('.mfsl.fcb strong')[0].innerText"];
    
    //autofill the form
    url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
    nameLbl.text = url;
    NSLog(@"%@",url);
    
    infoLbl.text = [NSString stringWithFormat:searchString,phoneNumberSearch];
    
    backButton.hidden = NO;
    contactButton.hidden = YES;
    numberTextField.hidden = YES;
    numberTextField.text = @"";
    [web removeFromSuperview];
    first = NO;
    [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
    [self.view setUserInteractionEnabled:YES];
}

-(void)getImageFacebook
{
    NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"img[class='l img']\"); \
                                for (var i = inputFields.length >>> 0; i--;) { inputFields[i].src}"];
    
    //autofill the form
    NSString *url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
    if(url.length >0)
    {
        avaImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        urlImage = url;
    }
    else
    {
        NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='captcha_attempt']\"); \
                                    for (var i = inputFields.length >>> 0; i--;) { inputFields[i].type;}"];
        
        //autofill the form
        NSString *url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
        if(url.length !=0)
        {
            web.alpha = 1;
            self.view.userInteractionEnabled = YES;
            [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
            return;
        }
        else
        {
            [web loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://m.vk.com/restore"]]];
            [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
            [[ProgressViewManager sharedProgressViewManager] showWithTitle:@"Анализ vk"];
            first = NO;
            counter = 0;
            return;
        }
        
    }
    loadUsernameJS = [NSString stringWithFormat:@"document.querySelectorAll('.mfsl.fcb strong')[0].innerText"];
    
    //autofill the form
    url = [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
    nameLbl.text = url;
    NSLog(@"%@",url);
    infoLbl.text = [NSString stringWithFormat:searchString,phoneNumberSearch];
    numberTextField.hidden = YES;
    backButton.hidden = NO;
    contactButton.hidden = YES;
    numberTextField.text = @"";
    [web removeFromSuperview];
    first = NO;
    [[ProgressViewManager sharedProgressViewManager] dismissProgressView];
    [self.view setUserInteractionEnabled:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)phoneChanged:(id)sender {
    phoneNumberSearch = ((UITextField*)sender).text;
}
- (IBAction)checkContacts {
    //[self getAllContacts];
    ABPeoplePickerNavigationController *peoplePickerController =
    [[ABPeoplePickerNavigationController alloc] init];
    [[peoplePickerController navigationBar] setBarStyle:UIBarStyleBlack];
    peoplePickerController.peoplePickerDelegate = self;
    
    [self presentViewController:peoplePickerController animated:YES completion:nil];
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSArray* phoneNumbers = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
    CFRelease(phoneNumberProperty);
    // do something with name.. and release
    phoneNumberSearch = phoneNumbers[0];
    numberTextField.text = phoneNumberSearch;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self voiceNumber];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}
- (IBAction)imageClick:(UIButton *)sender {
    if(avaImage.isHidden)
        return;
    [self searchByImage:urlImage];
}

- (IBAction)searchName {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    WebViewController *controller = (WebViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"WebViewController"];
    controller.url = @"";
    if(nameLbl.text.length > 0){
        controller.name = nameLbl.text;
        NSLog(@"%@",self.navigationController.navigationBar);
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:NULL];
    }
}


@end

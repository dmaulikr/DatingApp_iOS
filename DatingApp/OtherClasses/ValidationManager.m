//
//  ValidationManager.m
//  CrashPad
//
//  Created by lmsindia.
//  Copyright 2009 . All rights reserved.
//

#import "ValidationManager.h"
#import "RegexKitLite.h"


@implementation ValidationManager

// Validate email id URL's
+(BOOL) validateEmailID:(NSString *)emailId {
//	return [emailId isMatchedByRegex:@"^([a-zA-Z0-9_\\-\\.+-]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4})(\\]?)$"];
	NSArray *arr1=[emailId  componentsSeparatedByString:@"@"];
	NSString *str=[arr1 lastObject];
	int count=(int)[[str componentsSeparatedByString:@"."]count];
	if(count>=4)
		return NO;
	else
		return [emailId isMatchedByRegex:@"^([a-zA-Z0-9_\\-\\.+-]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4})(\\]?)$"];
}

// Validate Name Strings
+ (BOOL) validateName:(NSString *)nameString {
	return [nameString isMatchedByRegex:@"^([A-Za-z](\\.)?+(\\s)?[A-Za-z|\\'|\\.]*){1,60}$"];
}

// Validate Phone Number Strings
+(BOOL) validatePhoneNumber:(NSString *)phoneNumber {
	//return [phoneNumber isMatchedByRegex:@"^(1\\s*[-\\/\\.]?)?(\\((\\d{3})\\)|(\\d{3}))\\s*[-\\/\\.]?\\s*(\\d{3})\\s*[-\\/\\.]?\\s*(\\d{4})\\s*(([xX]|[eE][xX][tT])\\.?\\s*(\\d+))*$"];
   
	return [phoneNumber isMatchedByRegex:@"^[+]?([0-9]*[\\.\\s\\-\\(\\)]|[0-9]+){3,24}$"];
}

// Validate Note Strings
+(BOOL) validateNoteStrings:(NSString *)noteString {
	return [noteString isMatchedByRegex:@"^[A-Za-z0-9|\\'|\\.|\\,]*"];
}

// Validate ZIP Strings
+(BOOL) validateZipCode:(NSString *)zipCode {
	return [zipCode isMatchedByRegex:@"(^\\d{4}-\\d{4}|\\d{4}|[A-Z]\\d[A-Z] \\d[A-Z]|\\D{1}\\d{1}\\D{1}\\-?\\d{1}\\D{1}\\d$)"];
}

// Validate Number Strings
+(BOOL) validateNumber:(NSString *)numString {
	return [numString isMatchedByRegex:@"^[0-9]*$"];
}

// Validate password Strings
+(BOOL) validatePassword:(NSString *)password {
	return [password isMatchedByRegex:@"^([a-zA-Z0-9@*#+;:<>_-]{4,15})$"];
}

// Validate username Strings
+(BOOL) validateUsername:(NSString *)username {
	return [username isMatchedByRegex:@"^([a-zA-Z0-9]{1,25})$"];
}

// Validate Web URL
+(BOOL) validateWebURL:(NSString *)webURL {
	return [webURL isMatchedByRegex:@"^(((ht|f)tp(s?))\\:\\/\\/)?(www.|[a-zA-Z].)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,6})(\\:[0-9]+)*(\\/($|[a-zA-Z0-9\\.\\,\\;\?\\'\\\\\\+&%\\$#\\=~_\\-]+))*$"];
}

@end

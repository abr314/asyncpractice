//
//  ViewController.m
//  asyncpractice
//
//  Created by Abraham Brovold on 1/21/15.
//  Copyright (c) 2015 Abraham Brovold. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURL* url = [NSURL URLWithString:@"https://hopscotch-ios-test.herokuapp.com/projects"];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse* response,
                                               NSData* data,
                                               NSError* error)
    {
        if (data) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            // check status code and possibly MIME type (which shall start with "application/json"):
            NSRange range = [response.MIMEType rangeOfString:@"application/json"];
            
            if (httpResponse.statusCode == 200 /* OK */ && range.length != 0) {
                NSError* error;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (jsonObject) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // self.model = jsonObject;
                        NSLog(@"jsonObject: %@", jsonObject);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self handleError:error];
                        NSLog(@"ERROR: %@", error);
                    });
                }
            }
            else {
                // status code indicates error, or didn't receive type of data requested
                NSString* desc = [[NSString alloc] initWithFormat:@"HTTP Request failed with status code: %d (%@)",
                                  (int)(httpResponse.statusCode),
                                  [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                NSError* error = [NSError errorWithDomain:@"HTTP Request"
                                                     code:-1000
                                                 userInfo:@{NSLocalizedDescriptionKey: desc}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self handleError:error];  // execute on main thread!
                    NSLog(@"ERROR: %@", error);
                });
            }
        }
        else {
            // request failed - error contains info about the failure
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self handleError:error]; // execute on main thread!
                NSLog(@"ERROR: %@", error);
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

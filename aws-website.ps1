<#Create an AWS S3 Bucket to Host A Website#>
<#
https://aws.amazon.com/powershell/
http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi - download latest version of SDK with PS Module
#>
#Show loaded AWS module and supported services
<#
AWS Tools for Windows PowerShell
Version 3.1.32.0
Copyright 2012-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Amazon Web Services SDK for .NET
Version 3.1.4.1
Copyright 2009-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
...
#>
<# F8 to RUN SELECTION in VS Code #>
Get-AWSPowerShellVersion -ListServiceVersionInfo
#Set AWS Credentials - stored in AppData\Local\Amazon

#Get a list of profiles
get-awscredentials -ListProfiles
<#
MyAWSCreds
default
#>
#Set default creds (from file) and region
Initialize-AWSDefaults -ProfileName default -Region us-east-1

#echo $profile
<#I:\Users\EricFlamm\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1#>

#Verify default region 
Get-DefaultAWSRegion
<#
Region                                                 Name                                                   IsShellDefault                                       
------                                                 ----                                                   --------------                                       
us-east-1                                              US East (Virginia)                                     True            
#>

#List cmdlets for S3
#Get-AWSCmdletName -Service S3
<#
CmdletName                                             ServiceOperation                                       ServiceName                                          
----------                                             ----------------                                       -----------                                          
Copy-S3Object                                          CopyObject                                             Amazon Simple Storage Service                        
Get-S3ACL                                              GetACL                                                 Amazon Simple Storage Service                        
Get-S3Bucket                                           ListBuckets                                            Amazon Simple Storage Service                        
Get-S3BucketLocation                                   GetBucketLocation                                      Amazon Simple Storage Service                        
Get-S3BucketLogging                                    GetBucketLogging                                       Amazon Simple Storage Service                        
Get-S3BucketNotification                               GetBucketNotification                                  Amazon Simple Storage Service                        
Get-S3BucketPolicy                                     GetBucketPolicy                                        Amazon Simple Storage Service                        
Get-S3BucketReplication                                GetBucketReplication                                   Amazon Simple Storage Service                        
Get-S3BucketRequestPayment                             GetBucketRequestPayment                                Amazon Simple Storage Service                        
Get-S3BucketTagging                                    GetBucketTagging                                       Amazon Simple Storage Service                        
Get-S3BucketVersioning                                 GetBucketVersioning                                    Amazon Simple Storage Service                        
Get-S3BucketWebsite                                    GetBucketWebsite                                       Amazon Simple Storage Service                        
Get-S3CORSConfiguration                                GetCORSConfiguration                                   Amazon Simple Storage Service                        
Get-S3LifecycleConfiguration                           GetLifecycleConfiguration                              Amazon Simple Storage Service                        
Get-S3Object                                           ListObjects                                            Amazon Simple Storage Service                        
Get-S3ObjectMetadata                                   GetObjectMetadata                                      Amazon Simple Storage Service                        
Get-S3PreSignedURL                                     GetPreSignedURL                                        Amazon Simple Storage Service                        
Get-S3Version                                          ListVersions                                           Amazon Simple Storage Service                        
New-S3Bucket                                           PutBucket                                              Amazon Simple Storage Service                        
Remove-S3Bucket                                        DeleteBucket                                           Amazon Simple Storage Service                        
Remove-S3BucketPolicy                                  DeleteBucketPolicy                                     Amazon Simple Storage Service                        
Remove-S3BucketReplication                             DeleteBucketReplication                                Amazon Simple Storage Service                        
Remove-S3BucketTagging                                 DeleteBucketTagging                                    Amazon Simple Storage Service                        
Remove-S3BucketWebsite                                 DeleteBucketWebsite                                    Amazon Simple Storage Service                        
Remove-S3CORSConfiguration                             DeleteCORSConfiguration                                Amazon Simple Storage Service                        
Remove-S3LifecycleConfiguration                        DeleteLifecycleConfiguration                           Amazon Simple Storage Service                        
Remove-S3Object                                        DeleteObjects                                          Amazon Simple Storage Service                        
Restore-S3Object                                       RestoreObject                                          Amazon Simple Storage Service                        
Set-S3ACL                                              SetACL                                                 Amazon Simple Storage Service                        
Write-S3BucketLogging                                  PutBucketLogging                                       Amazon Simple Storage Service                        
Write-S3BucketNotification                             PutBucketNotification                                  Amazon Simple Storage Service                        
Write-S3BucketPolicy                                   PutBucketPolicy                                        Amazon Simple Storage Service                        
Write-S3BucketReplication                              PutBucketReplication                                   Amazon Simple Storage Service                        
Write-S3BucketRequestPayment                           PutBucketRequestPayment                                Amazon Simple Storage Service                        
Write-S3BucketTagging                                  PutBucketTagging                                       Amazon Simple Storage Service                        
Write-S3BucketVersioning                               PutBucketVersioning                                    Amazon Simple Storage Service                        
Write-S3BucketWebsite                                  PutBucketWebsite                                       Amazon Simple Storage Service                        
Write-S3CORSConfiguration                              PutCORSConfiguration                                   Amazon Simple Storage Service                        
Write-S3LifecycleConfiguration                         PutLifecycleConfiguration                              Amazon Simple Storage Service                        
#>

#Create a new bucket
New-S3Bucket -BucketName website-eflamm
<#
CreationDate                                                                      BucketName                                                                       
------------                                                                      ----------                                                                       
12/8/2015 9:05:41 PM                                                              website-eflamm                                                                   
#>
#Drop and restore bucket with designated region - still doesn't return a location
Remove-S3Bucket -BucketName website-eflamm
<#
ResponseMetadata                                       ContentLength                                          HttpStatusCode                                       
----------------                                       -------------                                          --------------                                       
Amazon.Runtime.ResponseMetadata                        -1                                                     NoContent                                            
#>

New-S3Bucket -BucketName website-eflamm -Region us-east-1
<#
CreationDate                                                                      BucketName                                                                       
------------                                                                      ----------                                                                       
12/8/2015 9:07:13 PM                                                              website-eflamm                                                                   
#>
#Write website configuration info to bucket - website location uses bucket name
Write-S3BucketWebsite -BucketName website-eflamm -WebsiteConfiguration_IndexDocumentSuffix index.html -WebsiteConfiguration_ErrorDocument error.html
#Verify Info
Get-S3BucketWebsite -BucketName website-eflamm
<#
ErrorDocument                            IndexDocumentSuffix                      RedirectAllRequestsTo                    RoutingRules                            
-------------                            -------------------                      ---------------------                    ------------                            
error.html                               index.html                                                                        {}                                      
#>
#upload files from current directory(T:\aws-website)
<#tutorial says CannedACL value is PublicRead - I could only get it to work with public-read, per AWS documentation - http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#CannedACL - which may not have anything to do with PowerShell
NoACL also succeeds, but website is inaccessible#>
cd T:\aws-website
foreach ($f in "index.html","error.html") {Write-S3Object -BucketName website-eflamm -File $f -Key $f -CannedACLName Public-Read}

<#
Website URL: http://website-eflamm.s3-website-us-east-1.amazonaws.com
#>
#delete the bucket and content
Remove-S3Bucket -BucketName website-eflamm -DeleteBucketContent
#Get list of buckets
Get-S3Bucket
<#
CreationDate                                                                      BucketName                                                                       
------------                                                                      ----------                                                                       
3/30/2015 12:27:25 PM                                                             appleseed2015                                                                    
7/9/2015 10:56:24 AM                                                              bhabackup                                                                        
#>
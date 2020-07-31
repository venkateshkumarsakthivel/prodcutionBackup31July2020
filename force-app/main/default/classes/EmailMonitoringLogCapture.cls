/*
Author : VENKATESH KUMAR
Purpose: Implemented as a part of P2PSUPPORT-241, to capture the outbound email message that gets triggered by the workflow.
Test Class : EmailMonitoringLogCaptureTest
*/

global class EmailMonitoringLogCapture implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
    
    // Create an InboundEmailResult object for returning the result of the 
    // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String myPlainText= '';
    String EmailMessEmailaddress = '';
    String EmailMessParentID = '';
    String strGrantedStatus = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    String strTaxiLicAUTHType =GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    
    // Add the email plain text into the local variable 
    myPlainText = email.plainTextBody;
    system.debug('myPlainText >>>>>> '+myPlainText);
    system.debug('email.subject >>>>>> '+email.subject);
    
    // Check the mail alert type using the mail subject, to get the parent ID
    if(email.subject.contains('Taxi Licence End Date Due Reminder')){

        // get plate number from the email body
        String getTaxiLicNo = email.plainTextBody.substringBetween (Label.TaxiReminderSubjectStart+' ',' '+Label.TaxiReminderSubjectEnd);
        system.debug('getTaxiLicNo >>>>>> '+getTaxiLicNo.trim());

        // Get Authorisation Info based on Authorisation Number
        Authorisation__c AuthInfo = [select ID,Is_ExpiryCaseCreated__c,Service_Provider__c,Plate_Number__c,Authorisation_Number__c,Service_Provider_Notice_Email__c from Authorisation__c where Name =: getTaxiLicNo.trim() and Status__c =: strGrantedStatus and Authorisation_Type__c =: strTaxiLicAUTHType LIMIT 1] ;
        system.debug('AuthInfo >>>>>> '+AuthInfo );
        EmailMessEmailaddress = AuthInfo.Service_Provider_Notice_Email__c;
        //EmailMessParentID = AuthInfo.Id;
        EmailMessParentID = AuthInfo.Service_Provider__c; // get Account ID
    }

    if(EmailMessEmailaddress != '' && EmailMessParentID != ''){
        // Insert New Email message based on the inbound email trigger
        EmailMessage[] newEmail = new EmailMessage[0];
            newEmail.add(new EmailMessage(FromAddress = email.fromAddress,
            FromName = email.fromName,
            ToAddress = EmailMessEmailaddress,
            Subject = email.subject,
            TextBody = email.plainTextBody,
            HtmlBody = email.htmlBody,
            RelatedToId = EmailMessParentID, 
            status = '3')); // Creates Email alert with status Sent (3)            
        insert newEmail;
        system.debug('newEmail>>>>>> '+newEmail);
    } else{
        Application_Log__c log = new Application_Log__c();
        log.Debug_Level__c = GlobalConstants.INFO;
        log.Message__c = 'Unable to find the parent record or Sent Email ID'+ ', Parent ID = '+EmailMessParentID+', Email Address ='+EmailMessEmailaddress;
        log.Source__c = 'emailTaxiLicExpiryReminder';
        log.Source_Function__c = 'handleInboundEmail';        
        insert log;
    }

    Messaging.InboundEmailResult msgResultreturn = new Messaging.InboundEmailResult();
    return msgResultreturn ;
}
}
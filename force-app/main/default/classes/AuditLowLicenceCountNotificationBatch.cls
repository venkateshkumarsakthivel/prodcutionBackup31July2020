/* Batch class to notify BAU team if platform licence count 
 * or FieldKo app licence count is reaching its limit
 */
global class AuditLowLicenceCountNotificationBatch implements Database.Batchable<sObject> {
  
  global final String query;
  public final String FIELDKO_APP_NAMESPACE = 'ArxxusRFMv1';
  public final String FIELDKO_NATIVE_APP_NAMESPACE = 'FieldKoNativev1';
  
  global AuditLowLicenceCountNotificationBatch() {
    
    query = 'SELECT LicenseDefinitionKey, Name, Status, TotalLicenses, UsedLicenses '+
            'FROM UserLicense WHERE Status = \'Active\' '+
            'AND LicenseDefinitionKey = \'AUL\'';
  }
  
  //Start method
  global Database.QueryLocator start(Database.BatchableContext BC) {
    
    return Database.getQueryLocator(query);
  }
  
  //Execute method
  global void execute(Database.BatchableContext BC, List<UserLicense> scope) {
    
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
    for(UserLicense tempUserLicence : scope) {
      
      if(tempUserLicence.UsedLicenses > tempUserLicence.TotalLicenses - 5) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{Label.Audit_Licence_Notification_Email});
        mail.setSenderDisplayName('P2P System User');
        mail.setSubject('Salesforce Platform Licence Count Alert');
        String body = 'Salesforce Platform licence has less than 5 licences remaining, new external auditors cannot be onboarded.';
        mail.setHtmlBody(body);
        
        mails.add(mail);
      }
    }
    
    Boolean licenceCountLow = FALSE;
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{Label.Audit_Licence_Notification_Email});
    mail.setSenderDisplayName('P2P System User');
    mail.setSubject('FieldKo App/FieldKo Native App Licence Count Alert');
    
    String body = '';
    
    body += '<table style="width:80%;border-collapse: collapse;border: 1px solid black;text-align:center; vertical-align:middle;">';
    body += '<tr><th style="border: 1px solid black">Name</th><th style="border: 1px solid black">Total Licences</th><th style="border: 1px solid black">Licences Consumed</th><th style="border: 1px solid black">Licences Remaining</th></tr>';
    
    PackageLicense fieldKoPackage = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
                                      ExpirationDate,Status FROM PackageLicense WHERE 
                                      NamespacePrefix = :FIELDKO_APP_NAMESPACE];
    
    if(fieldKoPackage.UsedLicenses > fieldKoPackage.AllowedLicenses - 5) {
       
       body += '<tr><td style="text-align:left; vertical-align:left;border: 1px solid black">FieldKo App</td><td style="border: 1px solid black">'+fieldKoPackage.AllowedLicenses+'</td>';
       body += '</td><td style="border: 1px solid black">'+fieldKoPackage.UsedLicenses+'</td>';
       body += '<td style="border: 1px solid black">'+(fieldKoPackage.AllowedLicenses - fieldKoPackage.UsedLicenses)+'</td></tr>'; 
       
       licenceCountLow = TRUE;
    }
    
    PackageLicense fieldKoNativePackage = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
                                           ExpirationDate,Status FROM PackageLicense WHERE 
                                           NamespacePrefix = :FIELDKO_NATIVE_APP_NAMESPACE];
                                           
    if(fieldKoNativePackage.UsedLicenses > fieldKoNativePackage.AllowedLicenses - 5) {
       
       
       body += '<tr><td style="text-align:left; vertical-align:left;border: 1px solid black">FieldKo Native App</td><td style="border: 1px solid black">'+fieldKoNativePackage.AllowedLicenses+'</td>';
       body += '</td><td style="border: 1px solid black">'+fieldKoNativePackage.UsedLicenses+'</td>';
       body += '<td style="border: 1px solid black">'+(fieldKoNativePackage.AllowedLicenses - fieldKoNativePackage.UsedLicenses)+'</td></tr>';
       
       licenceCountLow = TRUE;
    }
    
    body += '</table><p>FieldKo App or FieldKo Native App has less than 5 licences remaining, new external auditors cannot be onboarded.</p>';
    
    mail.setHtmlBody(body);
    
    if(licenceCountLow)
     mails.add(mail);
    
    if(mails.size() > 0)
     Messaging.sendEmail(mails);
  }
  
  //Finish method
  global void finish(Database.BatchableContext BC) {
        
  }
}
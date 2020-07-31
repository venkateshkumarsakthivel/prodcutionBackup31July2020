public with sharing class AuditNoticeCongaValidator {
    
    public void validateNoticeRecordBeforeSendingCongaEmail(List<Notice_Record__c> noticeRecords) {
        
        String errorMessage = 'Following fields should not contain %% -';
        
        for(Notice_Record__c noticeRecord : noticeRecords) {
            
            // Create Signature with Phone, Email and Mobile
            String congaSignature = '';
            
            //No more required as congaSignature is not generated using these code.
            /*
            if(noticeRecord.Authorised_Officer__c != null) {
                
                List<Contact> authOfficerContactList = [SELECT Id, Phone, MobilePhone, Email FROM Contact WHERE Id =: noticeRecord.Authorised_Officer__c];
                
                Contact authOfficerContact = null;
                if(authOfficerContactList.size() > 0) {
                    authOfficerContact = authOfficerContactList.get(0);
                }
                
                if(String.isNotEmpty(authOfficerContact.Phone)) {
                    congaSignature += authOfficerContact.Phone;
                }
                if(String.isNotEmpty(authOfficerContact.MobilePhone)) {
                    
                    if(String.isNotEmpty(congaSignature)) {
                        congaSignature += '<br/>';
                    }
                    
                    congaSignature += authOfficerContact.MobilePhone;
                }
                if(String.isNotEmpty(authOfficerContact.Email)) {
                    
                    if(String.isNotEmpty(congaSignature)) {
                        congaSignature += '<br/>';
                    }
                    
                    congaSignature += authOfficerContact.Email;
                }
                
                noticeRecord.Conga_Check_Signature__c = congaSignature;
            }
            */
                
            // Validation - Only for Audit Action Case Record Type - Case Status should be approved Before Sending Email
            List<Case> relatedCaseList = [SELECT Id, Record_Type_Dev_Name__c FROM Case WHERE Id =: noticeRecord.Case__c];
            Case relatedCase = null;
            
            if(relatedCaseList.size() > 0) {
                relatedCase = relatedCaseList.get(0);
            }
            
            noticeRecord.Display_Conga_Error_Message__c = false;
            noticeRecord.Conga_Error_Message__c = '';
            
            if(relatedCase != null && relatedCase.Record_Type_Dev_Name__c == 'Audit_Action_Case'
               && noticeRecord.Is_Related_Case_Approved__c == false)
            {
                noticeRecord.Display_Conga_Error_Message__c = true;
                noticeRecord.Conga_Error_Message__c = 'Case Status should be Approved before Sending Email. ';
            }
            
            // Populate fields Display_Conga_Error_Message__c and Conga_Error_Message__c
            // To be used in DC and DCL parameters in Conga Solution
            // Fields below were depreciated May 2020
            /*
            String fieldsWithError = '';
            
            if(noticeRecord.Record_Type_Dev_Name__c == 'Notice_to_Inspect'
               && (noticeRecord.Description_Text_Block_1__c.contains('%%')
                   || noticeRecord.Directions_Text_Block_1__c.contains('%%')
                   || noticeRecord.Directions_Text_Block_2__c.contains('%%'))) 
            {
                
                noticeRecord.Display_Conga_Error_Message__c = true;
                
                if(noticeRecord.Description_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_2__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 2';
                }
                
                noticeRecord.Conga_Error_Message__c = noticeRecord.Conga_Error_Message__c + errorMessage + fieldsWithError;
                
            } else if(noticeRecord.Record_Type_Dev_Name__c == 'Notice_to_Produce'
                      && (noticeRecord.Description_Text_Block_1__c.contains('%%')
                          || (String.isNotEmpty(noticeRecord.Description_Text_Block_2__c)
                              && noticeRecord.Description_Text_Block_2__c.contains('%%'))
                          || noticeRecord.Legislation_Text_Block_1__c.contains('%%')
                          || noticeRecord.Directions_Text_Block_1__c.contains('%%')
                          || noticeRecord.Directions_Text_Block_2__c.contains('%%'))) 
            {
                
                noticeRecord.Display_Conga_Error_Message__c = true;
                
                if(noticeRecord.Description_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 1';
                }
                if(noticeRecord.Description_Text_Block_2__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 2';
                }
                if(noticeRecord.Legislation_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Legislation Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 2';
                }
                
                noticeRecord.Conga_Error_Message__c = noticeRecord.Conga_Error_Message__c + errorMessage + fieldsWithError;
                
            } else if(noticeRecord.Record_Type_Dev_Name__c == 'Require_information_Tax'
                      && noticeRecord.Directions_Text_Block_1__c.contains('%%')) 
            {
                
                noticeRecord.Display_Conga_Error_Message__c = true;
                
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 1';
                }
                
                noticeRecord.Conga_Error_Message__c = noticeRecord.Conga_Error_Message__c + errorMessage + fieldsWithError;
                
            } else if(noticeRecord.Record_Type_Dev_Name__c == 'Improvement_Notice' 
                      && (noticeRecord.Description_Text_Block_1__c.contains('%%')
                          || noticeRecord.Description_Text_Block_2__c.contains('%%')
                          || noticeRecord.Description_Text_Block_3__c.contains('%%')
                          || noticeRecord.Legislation_Text_Block_1__c.contains('%%')
                          || noticeRecord.Directions_Text_Block_1__c.contains('%%')
                          || (String.isNotEmpty(noticeRecord.Recommendations_Text_Block_1__c)
                              && noticeRecord.Recommendations_Text_Block_1__c.contains('%%')))) 
            {
                
                noticeRecord.Display_Conga_Error_Message__c = true;
                
                if(noticeRecord.Description_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 1';
                }
                if(noticeRecord.Description_Text_Block_2__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 2';
                }
                if(noticeRecord.Description_Text_Block_3__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 3';
                }
                if(noticeRecord.Legislation_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Legislation Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 1';
                }
                if(String.isNotEmpty(noticeRecord.Recommendations_Text_Block_1__c)
                   && noticeRecord.Recommendations_Text_Block_1__c.contains('%%')) {
                       
                       fieldsWithError += ' ' + 'Recommendations Text Block 1';
                   }
                
                noticeRecord.Conga_Error_Message__c = noticeRecord.Conga_Error_Message__c + errorMessage + fieldsWithError;
                
            } else if(noticeRecord.Record_Type_Dev_Name__c == 'Prohibition_Notice'
                      && (noticeRecord.Description_Text_Block_1__c.contains('%%')
                          || noticeRecord.Description_Text_Block_2__c.contains('%%')
                          || noticeRecord.Description_Text_Block_3__c.contains('%%')
                          //|| noticeRecord.Legislation_Text_Block_1__c.contains('%%')
                          || noticeRecord.Directions_Text_Block_1__c.contains('%%')
                          || noticeRecord.Directions_Text_Block_2__c.contains('%%')
                          || (String.isNotEmpty(noticeRecord.Recommendations_Text_Block_1__c)
                              && noticeRecord.Recommendations_Text_Block_1__c.contains('%%')))) 
            {
                
                noticeRecord.Display_Conga_Error_Message__c = true;
                
                if(noticeRecord.Description_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 1';
                }
                if(noticeRecord.Description_Text_Block_2__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 2';
                }
                if(noticeRecord.Description_Text_Block_3__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Description Text Block 3';
                }
                //if(noticeRecord.Legislation_Text_Block_1__c.contains('%%')) {
                //    fieldsWithError += ' ' + 'Legislation Text Block 1';
                //}
                if(noticeRecord.Directions_Text_Block_1__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 1';
                }
                if(noticeRecord.Directions_Text_Block_2__c.contains('%%')) {
                    fieldsWithError += ' ' + 'Directions Text Block 2';
                }
                if(String.isNotEmpty(noticeRecord.Recommendations_Text_Block_1__c)
                   && noticeRecord.Recommendations_Text_Block_1__c.contains('%%')) {
                       
                       fieldsWithError += ' ' + 'Recommendations Text Block 1';
                   }
                
                noticeRecord.Conga_Error_Message__c = noticeRecord.Conga_Error_Message__c + errorMessage + fieldsWithError;
                
            } */
            
        }
        
    }
    
}
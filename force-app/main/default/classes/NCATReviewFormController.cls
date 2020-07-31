public without sharing class NCATReviewFormController{
    
    @AuraEnabled
    public static Boolean isValidateUser()
    {
        /*-------- This method is to  verify current User loggedin is authorised for case creation--------*/
        String userId = Userinfo.getUserId();
        String permissionSetName = 'Sanctions_Operations_Staff_level_2_level_3';
        Boolean isUserAuthorized ;
        isUserAuthorized = GlobalUtility.isUserHasAssignedPermissionSet(permissionSetName) ;
        return isUserAuthorized ;
    }
    
    
    @AuraEnabled
    public static String getAccountDetails(String accountId)
    {
        /*-------- This method is to  get account details-------*/
        try{
            // system.debug('in controller');
            Account acc = [SELECT Id, Name, Owner.Name FROM Account WHERE Id =: accountId]; 
            String accountDetail = JSON.serialize(acc);
            system.debug('Account Details: '+acc);
            return accountDetail;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NCATReviewFormController','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    
    @AuraEnabled
    public static String createNcatReviewCase(String caseString)
    {
        /*-------- This method is to  create new NcatReviewCase --------*/ 
        try{
            system.debug('in controller' + caseString);
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.NCAT_REVIEW_RECORD_TYPE).getRecordTypeId(); 
            Case caseDetail = (Case) JSON.deserialize(caseString, Case.class);
            Id authId = caseDetail.Authorisation__c;
            if(authId!= null)
            {
                Authorisation__c authRec= [select Id ,Authorisation_Type__c from Authorisation__C where Id =:authId];
                if(authRec.Authorisation_Type__c =='TSP' || authRec.Authorisation_Type__c =='BSP')
                {
                    caseDetail.Type='Service Provider' ;  
                }
                else 
                {
                    caseDetail.Type='Taxi' ; 
                }
            }
            caseDetail.RecordTypeId = recordTypeId;
            caseDetail.Sub_Type__c = GlobalConstants.NCAT_REVIEW_CASE_SUB_TYPE;
            caseDetail.Status = GlobalConstants.LODGED_CASE_STATUS;
            caseDetail.Sub_Status__c= GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
            caseDetail.OwnerId = UserInfo.getUserId();
            
            System.debug('casedetail before insert');
            Database.SaveResult saveCaseDetail = Database.insert(caseDetail, false);
            System.debug('savecaseDetail is'+ saveCaseDetail);
            
            if (saveCaseDetail.isSuccess()) {
                // System.debug('Successfully inserted ');
                System.debug('new case rec is '+caseDetail);
                Id accountId = caseDetail.AccountId;
                String attachmentPrefix = 'NCAT';
                List<Attachment> attachmentsToDelete = updateParentIdOnAttachment(accountId ,attachmentPrefix);
                List<Attachment> attachmentstoinsert = new List<Attachment>();
                if(attachmentsToDelete != null && attachmentsToDelete.size() > 0){
                    for(Attachment attachment : attachmentsToDelete){
                        Attachment attachmentToinsert = attachment.clone(false,true,false,false);
                        attachmentToinsert.ParentId = caseDetail.Id;
                        attachmentToinsert.Name = attachment.Name.remove(attachmentPrefix+'-');
                        attachmentstoinsert.add(attachmentToinsert);
                    }
                    
                    insert attachmentstoinsert;
                    GlobalUtility.ALLOW_FILE_DELETE = true;
                    delete  attachmentsToDelete;
                }
                /*----- to get Case number -----*/
                Case newCaseRec = [select Id ,CaseNumber from Case where Id= :caseDetail.Id];
                return JSON.serialize(newCaseRec) ;
                
            } else {
                return 'NOT CREATED';
            }
            
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NCATReviewFormController','createNcatReviewCase',ex.getMessage(),ex);
            return null;
        }
        
    }
    
    //This function is to return account attachment to update parent id with case
    private static List<Attachment> updateParentIdOnAttachment( string accountId,String attachmentPrefix){
        String attachmentPrefixForLike = attachmentPrefix+'%';
        List<Attachment> accountAttachments = [Select Id,Name,CreatedDate,Body,Description from Attachment where parentId = :accountId  and name LIKE :attachmentPrefixForLike order by createdDate desc ];
        return accountAttachments;
    }
}
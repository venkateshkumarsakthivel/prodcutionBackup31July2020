/*
 * Helper class to detect if audit case 
 * is approved or rejected and then accordingly create visits and 
 * add Lead Auditor to service provider's account team
 */
public without sharing class AuditCaseApprovalProcessor {
/*
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    private static BusinessHours businessHours;
    
    public final String GENERAL_QUESTIONS = 'General Questions';
    public final String PERSONS_INVOLVED_IN_AUDIT = 'Persons involved in audit';
    public final String AUDIT_FINDINGS = 'Initial Findings';
    public final String SERVICE_PROVIDER_SIGNATURE = 'Service Provider Signature';
    public final String AUDITORS_DECLARATION = 'Auditor\'s Declaration';
    public final String SERVICE_PROVIDER_FLEET = 'Service Provider Fleet';
    
    public AuditCaseApprovalProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        if(businessHours == null){
            businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
        }
        this.newCases = newCases;
        this.oldCases = oldCases;
    }
    
    public void processApprovedAuditCases() {    
       
     try {
        
        Map<String, String> accountIdVsLeadAuditorMap = new Map<String, String>();
        Map<String, ArxxusRFMv1__Visit_Template__c> targetVisitTemplateNamesVsVisitTemplatesMap = new Map<String, ArxxusRFMv1__Visit_Template__c>();
        Map<String, List<ArxxusRFMv1__Visit_Template_Entry__c>> targetVisitTemplateNamesVsVisitLineItems = new Map<String, List<ArxxusRFMv1__Visit_Template_Entry__c>>();
        Map<String, List<ArxxusRFMv1__Call_Cycle__c>> targetAuditUsersVsActiveCallCycles = new Map<String, List<ArxxusRFMv1__Call_Cycle__c>>();
        Map<Case, ArxxusRFMv1__Visit__c> auditCaseVsVisitsToInsert = new Map<Case, ArxxusRFMv1__Visit__c>();
        Map<ArxxusRFMv1__taskSurvey__c, ArxxusRFMv1__Tasks__c> tasksVsTaskSurveysToInsert = new Map<ArxxusRFMv1__taskSurvey__c, ArxxusRFMv1__Tasks__c>();
        Map<String, String> leadAuditorContactIdVsUserId = new Map<String, String>();
        Map<String, AccountTeamMember> userAccountIdVsAccountTeamMemberMap = new Map<String, AccountTeamMember>();
        
                
        Set<String> targetVisitTemplateNames = new Set<String>();
        Set<Case> targetAuditApprovalCases = new Set<Case>();
        Set<String> taskToUpdateIds = new Set<String>();
        
        List<ArxxusRFMv1__taskSurvey__c> taskSurveysToInsert = new List<ArxxusRFMv1__taskSurvey__c>();
        List<AccountTeamMember> accountTeamMembersToUpsert = new List<AccountTeamMember>();
        
        for(Case tempCase : newCases.values()) {
           
           System.debug('New Sub-Status: '+tempCase.Sub_Status__c);
           System.debug('Old Sub-Status: '+oldCases.get(tempCase.Id).Sub_Status__c);
           System.debug('Lead Auditor: '+tempCase.Lead_Auditor__c);
           System.debug('Lead Auditor Internal User: '+tempCase.Lead_Auditor_Internal_User__c);
          */
           /*
           if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
               && tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS
               && tempCase.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING
               && tempCase.Sub_Status__c != oldCases.get(tempCase.Id).Sub_Status__c
               && tempCase.Sub_Type__c != NULL) {
           */
    /*
           if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
               && tempCase.Notice_Email_Sent__c != oldCases.get(tempCase.Id).Notice_Email_Sent__c
               && tempCase.Notice_Email_Sent__c) {
                     
               targetAuditApprovalCases.add(tempCase);
               
               //determining the audit type and collecting visit template names to query for
               if(tempCase.Sub_Type__c == GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE
                  || tempCase.Sub_Type__c == GlobalConstants.LEVY_AUDIT_SUB_TYPE)
                  targetVisitTemplateNames.add(tempCase.Sub_Type__c);
               else if(tempCase.Sub_Type__c == GlobalConstants.SAFETY_SELECTED_AUDIT_SUB_TYPE) {
                  
                  String auditSelectionTools = tempCase.Audit_Tool_Sections__c;
                  targetVisitTemplateNames.add(GENERAL_QUESTIONS);
                  targetVisitTemplateNames.add(PERSONS_INVOLVED_IN_AUDIT);
                  targetVisitTemplateNames.add(AUDIT_FINDINGS);
                  targetVisitTemplateNames.add(SERVICE_PROVIDER_SIGNATURE);
                  targetVisitTemplateNames.add(AUDITORS_DECLARATION);
                  targetVisitTemplateNames.add(SERVICE_PROVIDER_FLEET);
                   
                  targetVisitTemplateNames.addAll(auditSelectionTools.split(';'));
               } 
               
               if(tempCase.AccountId != NULL && tempCase.Lead_Auditor__c != NULL)
                 accountIdVsLeadAuditorMap.put(tempCase.AccountId, tempCase.Lead_Auditor__c);
               
               if(tempCase.AccountId != NULL && tempCase.Lead_Auditor_Internal_User__c != NULL)
                 accountIdVsLeadAuditorMap.put(tempCase.AccountId, tempCase.Lead_Auditor_Internal_User__c); 
           }
        }  
        
        System.debug('Account Id Vs Auditor Map: '+accountIdVsLeadAuditorMap);
        if(accountIdVsLeadAuditorMap.isEmpty()){
            return;
        }
        //fetching all relevant call cycle records
        for(User tempLeadAuditor : [SELECT Id, FirstName, LastName, Audit_Contact_Id__c,
                                     (SELECT Name, ArxxusRFMv1__Call_Cycle_Start_Date__c, ArxxusRFMv1__Call_Cycle_End_Date__c,
                                       ArxxusRFMv1__IsActive__c, ArxxusRFMv1__Sales_Representative__c
                                       FROM ArxxusRFMv1__Call_Cycles__r
                                       WHERE ArxxusRFMv1__IsActive__c = TRUE)
                                    FROM User
                                    WHERE (Audit_Contact_Id__c IN :accountIdVsLeadAuditorMap.values()
                                           OR Id IN :accountIdVsLeadAuditorMap.values())]) {
           
              targetAuditUsersVsActiveCallCycles.put(tempLeadAuditor.Id, tempLeadAuditor.ArxxusRFMv1__Call_Cycles__r);
              String mapKey = String.isBlank(tempLeadAuditor.Audit_Contact_Id__c) ? tempLeadAuditor.Id : tempLeadAuditor.Audit_Contact_Id__c;
              leadAuditorContactIdVsUserId.put(mapKey, tempLeadAuditor.Id);
        }
        
        System.debug('Lead Contact Id Vs User Map: '+leadAuditorContactIdVsUserId);
        
        for(AccountTeamMember tempAccountTeamMember : [SELECT AccountAccessLevel, AccountId, CaseAccessLevel, OpportunityAccessLevel,
                                                        UserId, TeamMemberRole
                                                        FROM AccountTeamMember
                                                        WHERE (UserId IN :leadAuditorContactIdVsUserId.values()
                                                                OR AccountId IN :accountIdVsLeadAuditorMap.keySet())]) {
             
                  userAccountIdVsAccountTeamMemberMap.put(tempAccountTeamMember.AccountId+'-'+tempAccountTeamMember.UserId, tempAccountTeamMember);                                           
        }
        
        //fetching all relevant visit template records
        for(ArxxusRFMv1__Visit_Template__c tempVisitTemplate : [SELECT Name, Index__c, ArxxusRFMv1__Template_Name__c, ArxxusRFMv1__Description__c,
                                                                 (SELECT Name, ArxxusRFMv1__Index__c, ArxxusRFMv1__Survey__c, ArxxusRFMv1__Task_Type__c,
                                                                   ArxxusRFMv1__Task_Type__r.Name, ArxxusRFMv1__Visit_Template__c
                                                                   FROM ArxxusRFMv1__Visit_Template_Entries__r
                                                                   ORDER BY ArxxusRFMv1__Index__c ASC)
                                                                 FROM ArxxusRFMv1__Visit_Template__c
                                                                 WHERE ArxxusRFMv1__Template_Name__c IN :targetVisitTemplateNames
                                                                 ORDER BY Index__c]) {
           
              targetVisitTemplateNamesVsVisitTemplatesMap.put(tempVisitTemplate.ArxxusRFMv1__Template_Name__c, tempVisitTemplate);
              targetVisitTemplateNamesVsVisitLineItems.put(tempVisitTemplate.ArxxusRFMv1__Template_Name__c, tempVisitTemplate.ArxxusRFMv1__Visit_Template_Entries__r);
        }
        
        //iterating over audit cases for visit creation
        for(Case tempCase : targetAuditApprovalCases) {
          
          String mapKey = String.isBlank(tempCase.Lead_Auditor_Internal_User__c) ? tempCase.Lead_Auditor__c : tempCase.Lead_Auditor_Internal_User__c;
          
          AccountTeamMember tempAccountTeamMember = new AccountTeamMember();
          
          if(userAccountIdVsAccountTeamMemberMap.containsKey(tempCase.AccountId+'-'+leadAuditorContactIdVsUserId.get(mapKey)))
           tempAccountTeamMember = userAccountIdVsAccountTeamMemberMap.get(tempCase.AccountId+'-'+leadAuditorContactIdVsUserId.get(mapKey)); 
          else {
          
           tempAccountTeamMember.AccountId = tempCase.AccountId;
           tempAccountTeamMember.UserId = leadAuditorContactIdVsUserId.get(mapKey);
          }
          tempAccountTeamMember.AccountAccessLevel = 'Read';
          tempAccountTeamMember.TeamMemberRole = 'Auditor';
          
          accountTeamMembersToUpsert.add(tempAccountTeamMember); 
          
          ArxxusRFMv1__Visit__c tempVisitToInsert = new ArxxusRFMv1__Visit__c();
          tempVisitToInsert.ArxxusRFMv1__Store__c = tempCase.AccountId;
          tempVisitToInsert.ArxxusRFMv1__Status__c = 'Not Started';
          tempVisitToInsert.ArxxusRFMv1__Planned_Start__c = DateTime.newInstance(checkBusinessDay(tempCase.Audit_Target_Start_Date__c.addDays(1)), Time.newInstance(10, 0, 0, 0));
          tempVisitToInsert.ArxxusRFMv1__Planned_End__c = DateTime.newInstance(tempVisitToInsert.ArxxusRFMv1__Planned_Start__c.date(), Time.newInstance(17, 0, 0, 0));
          
          tempVisitToInsert.OwnerId = leadAuditorContactIdVsUserId.get(mapKey);
          tempVisitToInsert.ArxxusRFMv1__Sales_Representative__c = leadAuditorContactIdVsUserId.get(mapKey);
          
          
          tempVisitToInsert.Audit_Case__c = tempCase.Id;
          
          //if sub type is Safety Full Audit or Levy Audit, then set visit template on visit record 
          if((tempCase.Sub_Type__c == GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE
              || tempCase.Sub_Type__c == GlobalConstants.LEVY_AUDIT_SUB_TYPE)
             && targetVisitTemplateNamesVsVisitTemplatesMap.containsKey(tempCase.Sub_Type__c)) 
             tempVisitToInsert.ArxxusRFMv1__Visit_Template__c = targetVisitTemplateNamesVsVisitTemplatesMap.get(tempCase.Sub_Type__c).Id;
             
          tempVisitToInsert.Name = '['+tempCase.CaseNumber+'] '+tempCase.Sub_Type__c+' - '+tempCase.Account_Name__c;
          tempVisitToInsert.Name = tempVisitToInsert.Name.length() > 80 ? tempVisitToInsert.Name.left(80) : tempVisitToInsert.Name;
          
             
          if(targetAuditUsersVsActiveCallCycles.containsKey(tempCase.Lead_Auditor__c)) {
               
           for(ArxxusRFMv1__Call_Cycle__c tempCallCycle : targetAuditUsersVsActiveCallCycles.get(tempCase.Lead_Auditor__c)) {
                 
             //checking if audit date is within lead auditor's call cycle
             if(tempCase.Audit_Target_Start_Date__c >= tempCallCycle.ArxxusRFMv1__Call_Cycle_Start_Date__c
                 && tempCase.Audit_Target_Start_Date__c <= tempCallCycle.ArxxusRFMv1__Call_Cycle_End_Date__c) {
                     
                   tempVisitToInsert.ArxxusRFMv1__Call_Cycle__c = tempCallCycle.Id;
                   break;      
             }
            }
           }
             
           System.debug('Visit Insertion Result: '+tempVisitToInsert.ArxxusRFMv1__Planned_Start__c);
           System.debug('Visit Insertion Result: '+tempVisitToInsert.ArxxusRFMv1__Planned_End__c);
        
           auditCaseVsVisitsToInsert.put(tempCase, tempVisitToInsert);
        }
        
        List<Database.UpsertResult> accountTeamMemberUpsertResult = Database.upsert(accountTeamMembersToUpsert, FALSE);
        List<Database.SaveResult> visitInsertionResult = Database.insert(auditCaseVsVisitsToInsert.values(), FALSE);
        System.debug('Visit Insertion Result: '+visitInsertionResult);
        
        //iterating over the list of visits that were inserted
        for(Case tempCase : auditCaseVsVisitsToInsert.keySet()) {
           
           String mapKey = String.isBlank(tempCase.Lead_Auditor_Internal_User__c) ? tempCase.Lead_Auditor__c : tempCase.Lead_Auditor_Internal_User__c;
           
           //means visit was successfully inserted 
           if(String.isNotBlank(auditCaseVsVisitsToInsert.get(tempCase).Id)) {
             
             Set<String> auditCaseVisitTemplateNames = new Set<String>();
             Integer taskTypeIndex = 0;
             
             //determining the audit type and collecting visit template names to query for
             if(tempCase.Sub_Type__c == GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE
                  || tempCase.Sub_Type__c == GlobalConstants.LEVY_AUDIT_SUB_TYPE)
                  auditCaseVisitTemplateNames.add(tempCase.Sub_Type__c);
             else if(tempCase.Sub_Type__c == GlobalConstants.SAFETY_SELECTED_AUDIT_SUB_TYPE) {
                  
                  String auditSelectionTools = tempCase.Audit_Tool_Sections__c;
                  auditCaseVisitTemplateNames.add(GENERAL_QUESTIONS);
                  auditCaseVisitTemplateNames.add(PERSONS_INVOLVED_IN_AUDIT);
                  auditCaseVisitTemplateNames.add(AUDIT_FINDINGS);
                  auditCaseVisitTemplateNames.add(SERVICE_PROVIDER_SIGNATURE);
                  auditCaseVisitTemplateNames.add(AUDITORS_DECLARATION);
                  auditCaseVisitTemplateNames.add(SERVICE_PROVIDER_FLEET);
                  auditCaseVisitTemplateNames.addAll(auditSelectionTools.split(';'));
             } 
             
             System.debug('Sections Selected: '+auditCaseVisitTemplateNames);
             System.debug('Sections Map: '+targetVisitTemplateNamesVsVisitLineItems);
             
             //fetching all relevant visit template records
             for(ArxxusRFMv1__Visit_Template__c tempVisitTemplate : [SELECT Name, Index__c, ArxxusRFMv1__Template_Name__c, ArxxusRFMv1__Description__c,
                                                                      (SELECT Name, ArxxusRFMv1__Index__c, ArxxusRFMv1__Survey__c, ArxxusRFMv1__Task_Type__c,
                                                                        ArxxusRFMv1__Task_Type__r.Name, ArxxusRFMv1__Visit_Template__c
                                                                        FROM ArxxusRFMv1__Visit_Template_Entries__r
                                                                        ORDER BY ArxxusRFMv1__Index__c ASC)
                                                                        FROM ArxxusRFMv1__Visit_Template__c
                                                                        WHERE ArxxusRFMv1__Template_Name__c IN :auditCaseVisitTemplateNames
                                                                        ORDER BY Index__c]) {
               
               List<ArxxusRFMv1__Visit_Template_Entry__c> visitTemplateEntries = targetVisitTemplateNamesVsVisitLineItems.containsKey(tempVisitTemplate.ArxxusRFMv1__Template_Name__c) ? targetVisitTemplateNamesVsVisitLineItems.get(tempVisitTemplate.ArxxusRFMv1__Template_Name__c) : new List<ArxxusRFMv1__Visit_Template_Entry__c>();
               for(ArxxusRFMv1__Visit_Template_Entry__c tempVisitTemplateEntry : visitTemplateEntries) {
                 
                 ArxxusRFMv1__Tasks__c tempAuditTask = new ArxxusRFMv1__Tasks__c();
                 tempAuditTask.Name = tempVisitTemplateEntry.ArxxusRFMv1__Task_Type__r.Name;
                 tempAuditTask.ArxxusRFMv1__Visit__c = auditCaseVsVisitsToInsert.get(tempCase).Id;
                 tempAuditTask.ArxxusRFMv1__Task_Type__c = tempVisitTemplateEntry.ArxxusRFMv1__Task_Type__c;
                 tempAuditTask.ArxxusRFMv1__Index__c = taskTypeIndex;
                 tempAuditTask.ArxxusRFMv1__Due_Date__c = auditCaseVsVisitsToInsert.get(tempCase).ArxxusRFMv1__Planned_End__c;
                 tempAuditTask.OwnerId = leadAuditorContactIdVsUserId.get(mapKey);
                */ 
                 /*
                   On purpose setting status to in progress as statistics calculation
                   done by FieldKo is running in some permission issue and failing to calculate.
                   In future method updating back status to Not Started so that statistics 
                   are getting calculated correctly.
                 */
    /*
                 tempAuditTask.ArxxusRFMv1__status__c = GlobalConstants.VISIT_STATUS_IN_PROGRESS;
                 
                 ArxxusRFMv1__taskSurvey__c tempAuditTaskSurvey = new ArxxusRFMv1__taskSurvey__c();
                 tempAuditTaskSurvey.ArxxusRFMv1__Visit__c = auditCaseVsVisitsToInsert.get(tempCase).Id;
                 tempAuditTaskSurvey.ArxxusRFMv1__survey__c = tempVisitTemplateEntry.ArxxusRFMv1__Survey__c;
                 
                 tasksVsTaskSurveysToInsert.put(tempAuditTaskSurvey, tempAuditTask);
                 taskTypeIndex++;
               }
             }         
           }
        }
        
        if(tasksVsTaskSurveysToInsert.size() > 0) {
           
           List<Database.SaveResult> tasksInsertionResult = Database.insert(tasksVsTaskSurveysToInsert.values(), FALSE);
           System.debug('Task Insertion Result: '+tasksInsertionResult);
           
           for(ArxxusRFMv1__Tasks__c tempAuditTask : tasksVsTaskSurveysToInsert.values()) {
              
              //tempAuditTask.ArxxusRFMv1__status__c = GlobalConstants.VISIT_STATUS_NOT_STARTED;
              taskToUpdateIds.add(tempAuditTask.Id);
           }
           
           //future call out to update tasks to Not Started
           if(taskToUpdateIds.size() > 0)
             updateRelatedTasks(taskToUpdateIds);
           
           for(ArxxusRFMv1__taskSurvey__c tempTaskSurvey : tasksVsTaskSurveysToInsert.keySet()) {
              
              tempTaskSurvey.ArxxusRFMv1__task__c = tasksVsTaskSurveysToInsert.get(tempTaskSurvey).Id;
              taskSurveysToInsert.add(tempTaskSurvey);
           }
           
           if(taskSurveysToInsert.size() > 0) {
              
              List<Database.SaveResult> taskSurveysInsertionResult = Database.insert(taskSurveysToInsert, FALSE);
              System.debug('Task Survey Insertion Result: '+taskSurveysInsertionResult);
           }
        }
     }
     catch(Exception ex) {
        
       System.debug(ex.getLineNumber());
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseClosedProcessor','processClosedAuditCases',ex.getMessage(),ex);                        
     }
    }
    
    //Check if parameter date is business day else return next business day
    public Date checkBusinessDay(Date paymentDueDate) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, paymentDueDate);
        
        if(isInBusinessHours) {
            return paymentDueDate;
        } else {
            paymentDueDate = paymentDueDate.addDays(1);
            return checkBusinessDay(paymentDueDate);
        }
    }
    
    @future
    public static void updateRelatedTasks(Set<String> relatedTaskIds) {
      
        List<ArxxusRFMv1__Tasks__c> tasksToUpdate = new List<ArxxusRFMv1__Tasks__c>();
        
        for(ArxxusRFMv1__Tasks__c tempAuditTask : [SELECT ArxxusRFMv1__status__c 
                                                    FROM ArxxusRFMv1__Tasks__c
                                                    WHERE Id IN :relatedTaskIds]) {
            
            tempAuditTask.ArxxusRFMv1__status__c = GlobalConstants.VISIT_STATUS_NOT_STARTED;
            tasksToUpdate.add(tempAuditTask);                   
        }
                                                          
        Database.update(tasksToUpdate, FALSE);
    }
*/
}
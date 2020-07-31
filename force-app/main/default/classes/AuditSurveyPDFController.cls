public without sharing class AuditSurveyPDFController {
    
    public AuditSurveyPDFController(){
        
        
    }
    /*
    public static final String INITIAL_FINDINGS = 'Initial Findings';
    public static final String AUDIT_FINDINGS = 'Audit Findings';
    public static final String AUDITORS_DECLARATION = 'Auditor\'s Declaration';
    public static final String SERVICE_PROVIDER_SIGNATURE = 'Service Provider Signature';
    public static final String FINAL_NOTES_AND_COMMENTS = 'Final Notes and Comments';
    
    public List<String> Tasks {get;set;}
    public List<taskSurveyData> taskSurveys {get;set;}
    public List<taskSurveyData> initialFindingsTaskSurveys {get;set;}
    public List<taskSurveyData> initialFindingsTaskSurveysForAuditSummaryPage {get;set;}
    public List<taskSurveyData> detailedFindingsTaskSurveys {get;set;}
    public List<String> auditSectionNames {get;set;}
    public Map<String, List<String>> auditSectionNamesMap {get; set;}
    
    List<String> surveyId;
    List<String> taskSurveyIdList ;
    
    public HeaderInfo headerInformation {get;set;}
    
    public Map<String,String> taskSurveyVsInstruction = new Map<String,String>();  
    Map<String,List<String>> visitVsTaskSurveys;
    Map<String,List<ArxxusRFMv1__taskSurveyAnswer__c>> taskSurveyVsSurveyAnswers;
    Map<String,Decimal> surveyQuestionVsIndex;
    Map<String,taskSurveyAnswerData> parentVsChildMap;
    
    private final Integer PDF_SIZE_LIMIT = 22 * 1024 * 1024;
    
    public AuditSurveyPDFController() {        
        
        headerInformation = new HeaderInfo();
        String visitId = ApexPages.currentPage().getParameters().get('id');
        processActualData(visitId);
    }
    
    public void processActualData(String visitId) {
        
        initHeaderInformation(visitId);
        List<ArxxusRFMv1__Visit__c> visits = [SELECT Id, ArxxusRFMv1__Store__c,ArxxusRFMv1__Store__r.ParentId, ArxxusRFMv1__Store__r.RecordTypeId,
                                               (SELECT Id, Name, ArxxusRFMv1__survey__c, ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c 
                                                 From ArxxusRFMv1__Task_Surveys__r ORDER BY ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c) 
                                               From ArxxusRFMv1__Visit__c WHERE Id = :visitId]; 
        
        populateDataInVisitMap(visits);
        populateDataInTaskSurveyMap();
        populateDateFromSurveyQuestion();
        sendRecords(visitId,visitVsTaskSurveys,taskSurveyVsSurveyAnswers);
        
        initialFindingsTaskSurveys = populateAnswersImageId(initialFindingsTaskSurveys, taskSurveyVsSurveyAnswers);
        
        initialFindingsTaskSurveysForAuditSummaryPage = updateDataForAuditSummaryPage(initialFindingsTaskSurveys);
    }
    
    //Fetch and Initialise wrapper for Header Information
    private void initHeaderInformation(String visitId) {
        
        ArxxusRFMv1__Visit__c visitRec = [SELECT Id, Name, Owner.Name, ArxxusRFMv1__Store__r.Name, ArxxusRFMv1__Store__r.Owner.Name,
                                            ArxxusRFMv1__Store__r.RecordType.Name, ArxxusRFMv1__Planned_Start__c,
                                            ArxxusRFMv1__Status__c, ArxxusRFMv1__Actual_End__c, ArxxusRFMv1__Actual_Start__c,
                                            Audit_Case__c, Audit_Case__r.Sub_Type__c, Audit_Case__r.Contact.Name,
                                            ArxxusRFMv1__Store__r.ABN__c, ArxxusRFMv1__Store__r.Registered_Business_Name__c, 
                                            ArxxusRFMv1__Store__r.Authorisation_Details__c, ArxxusRFMv1__Store__r.Account_Street_Address__c,
                                            Audit_Case__r.Lead_Auditor__r.Name, Audit_Case__r.Lead_Auditor__r.Account.Name, 
                                            Audit_Case__r.Lead_Auditor__r.Phone, Audit_Case__r.Lead_Auditor__r.MobilePhone, Audit_Case__r.Lead_Auditor__r.Email,
                                            ArxxusRFMv1__Store__r.BillingAddress,ArxxusRFMv1__Store__r.Phone,ArxxusRFMv1__Store__r.Email__c,
                                            ArxxusRFMv1__Store__r.Notice_Address__c,ArxxusRFMv1__Store__r.Notice_Address_Postal_Code__c,
                                            Audit_Case__r.Audit_Vendor__r.Name, ArxxusRFMv1__Store__r.Fax,
                                            ArxxusRFMv1__Store__r.BillingStreet, ArxxusRFMv1__Store__r.BillingCity, ArxxusRFMv1__Store__r.BillingState, ArxxusRFMv1__Store__r.BillingPostalCode, ArxxusRFMv1__Store__r.BillingCountry,
                                            ArxxusRFMv1__Store__r.ShippingStreet, ArxxusRFMv1__Store__r.ShippingCity, ArxxusRFMv1__Store__r.ShippingState, ArxxusRFMv1__Store__r.ShippingPostalCode, ArxxusRFMv1__Store__r.ShippingCountry, 
                                            ArxxusRFMv1__Store__r.Authorisation_Numbers_for_Audit__c, Audit_Case__r.Sub_Status__c 
                                          FROM ArxxusRFMv1__Visit__c 
                                          WHERE Id =: visitId LIMIT 1];              
       
        List<Period> periodList = [SELECT Id,Number From Period Where Type = 'Quarter' 
                                    AND StartDate <= :visitRec.ArxxusRFMv1__Planned_Start__c.Date() 
                                    AND EndDate >= :visitRec.ArxxusRFMv1__Planned_Start__c.Date() Limit 1];    
        
        if(periodList.size() > 0) {
            
            headerInformation.description = 'Quarter '+String.valueOf(periodList[0].Number);
        }

        headerInformation.street 					= visitRec.ArxxusRFMv1__Store__r.ShippingStreet;
        headerInformation.city 						= visitRec.ArxxusRFMv1__Store__r.ShippingCity;
        headerInformation.state 					= visitRec.ArxxusRFMv1__Store__r.ShippingState;
        headerInformation.code 						= visitRec.ArxxusRFMv1__Store__r.ShippingPostalCode;
        headerInformation.country					= visitRec.ArxxusRFMv1__Store__r.ShippingCountry;
        headerInformation.storeId 					= visitRec.ArxxusRFMv1__Store__c;
        headerInformation.accountName 				= visitRec.ArxxusRFMv1__Store__r.Name;
        headerInformation.auditName 				= visitRec.Audit_Case__r.Sub_Type__c;
        headerInformation.accountABN 				= visitRec.ArxxusRFMv1__Store__r.ABN__c;
        headerInformation.accountRegisteredBusinessName = visitRec.ArxxusRFMv1__Store__r.Registered_Business_Name__c;
        headerInformation.contactName 				= visitRec.Audit_Case__r.Contact.Name;
        headerInformation.accountAuthDetails 		= visitRec.ArxxusRFMv1__Store__r.Authorisation_Numbers_for_Audit__c == NULL ? '' : visitRec.ArxxusRFMv1__Store__r.Authorisation_Numbers_for_Audit__c.removeEnd(';').replace(';', ',');
        headerInformation.fullAddress	 			= headerInformation.street+', '+headerInformation.city+', '+headerInformation.state;
        headerInformation.fullAddress 				+= ', '+headerInformation.code;
        headerInformation.accountPhone 				= visitRec.ArxxusRFMv1__Store__r.Phone;
        headerInformation.accountEmail 				= visitRec.ArxxusRFMv1__Store__r.Email__c;
        headerInformation.accountFax 				= visitRec.ArxxusRFMv1__Store__r.Fax;
        headerInformation.accountPostalAddress 		= visitRec.ArxxusRFMv1__Store__r.Notice_Address__c;
        headerInformation.accountPostalAddressCode 	= visitRec.ArxxusRFMv1__Store__r.Notice_Address_Postal_Code__c;
        headerInformation.auditGroup 				= visitRec.Audit_Case__r.Audit_Vendor__r.Name;
        headerInformation.accountBillingStreet 		= visitRec.ArxxusRFMv1__Store__r.BillingStreet;
        headerInformation.accountBillingCity 		= visitRec.ArxxusRFMv1__Store__r.BillingCity; 
        headerInformation.accountBillingState 		= visitRec.ArxxusRFMv1__Store__r.BillingState;
        headerInformation.accountBillingPostalCode 	= visitRec.ArxxusRFMv1__Store__r.BillingPostalCode;
        headerInformation.accountBillingCountry 	= visitRec.ArxxusRFMv1__Store__r.BillingCountry;
        headerInformation.auditSubStatus		 	= visitRec.Audit_Case__r.Sub_Status__c;
        
        if(visitRec.ArxxusRFMv1__Actual_Start__c != NULL){
        	headerInformation.actualStartDate = visitRec.ArxxusRFMv1__Actual_Start__c.format('dd/MM/yyyy');
           	headerInformation.actualStartTime = visitRec.ArxxusRFMv1__Actual_Start__c.format('h:mm a');
        }
        
        if(visitRec.ArxxusRFMv1__Actual_End__c != NULL) {
           headerInformation.actualEndDate = visitRec.ArxxusRFMv1__Actual_End__c.format('dd/MM/yyyy');
		   headerInformation.actualEndTime = visitRec.ArxxusRFMv1__Actual_End__c.format('h:mm a'); 
        }
        
        if(visitRec.Audit_Case__r.Lead_Auditor__c != NULL) {
            
            headerInformation.auditorName = visitRec.Audit_Case__r.Lead_Auditor__r.Name;
            headerInformation.auditorAccount = visitRec.Audit_Case__r.Lead_Auditor__r.Account.Name;
            //headerInformation.auditorPhone = visitRec.Audit_Case__r.Lead_Auditor__r.Phone;
            headerInformation.auditorPhone = visitRec.Audit_Case__r.Lead_Auditor__r.MobilePhone;
            headerInformation.auditorEmail = visitRec.Audit_Case__r.Lead_Auditor__r.Email;
        }
    }
    
    private void populateDataInVisitMap(List<ArxxusRFMv1__Visit__c> visits) {
       
        visitVsTaskSurveys = new Map<String,List<String>>();        
        taskSurveyIdList = new List<String>();
        surveyId = new List<String>();              
        List<String> taskIds;
        
        for(ArxxusRFMv1__Visit__c visitObj : visits) {
        
            if(!visitVsTaskSurveys.containsKey(visitObj.Id)) {
            
                System.debug('In IF****');
                taskIds = new List<String>();
                for(ArxxusRFMv1__taskSurvey__c taskSurObj : visitObj.ArxxusRFMv1__Task_Surveys__r) {
                
                    if(String.isNotEmpty(taskSurObj.ArxxusRFMv1__survey__c)) {
                        taskIds.add(taskSurObj.Id);
                    }
                    
                    taskSurveyIdList.add(taskSurObj.Id);
                    surveyId.add(taskSurObj.ArxxusRFMv1__survey__c);
                }
                visitVsTaskSurveys.put(visitObj.Id,taskIds);
            }
            else {
                
                System.debug('In Else****');
                List<String> tempTaskIds = new List<String>();
                for(ArxxusRFMv1__taskSurvey__c taskObj : visitObj.ArxxusRFMv1__Task_Surveys__r) {
                
                    //tempTaskIds.add(taskObj.Id);
                    if(String.isNotEmpty(taskObj.ArxxusRFMv1__survey__c)) {
                    
                        tempTaskIds.add(taskObj.Id);
                    }
                    
                    taskSurveyIdList.add(taskObj.Id);
                    surveyId.add(taskObj.ArxxusRFMv1__survey__c);
                }
                visitVsTaskSurveys.get(visitObj.Id).addAll(tempTaskIds);
            }
        }
        System.debug('In populateDataInVisitMap******* : '+visitVsTaskSurveys);
    }
    
    private void populateDataInTaskSurveyMap() {
       
        taskSurveyVsSurveyAnswers = new Map<String,List<ArxxusRFMv1__taskSurveyAnswer__c>>();
        auditSectionNames = new List<String>();
        auditSectionNamesMap = new Map<String, List<String>>();
            
        auditSectionNamesMap.put('1-Initial Findings (Closing Meeting)', new List<String>());
        auditSectionNamesMap.put('2-Audit Details', new List<String>{'Service Provider', 'Auditor'});
        auditSectionNamesMap.put('3-Audit Questions', new List<String>());
        auditSectionNamesMap.put('4-Detailed Findings', new List<String>());
        
        for(ArxxusRFMv1__taskSurvey__c tskSurvey : [SELECT Id,ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c, ArxxusRFMv1__task__r.Name,
                                                               ArxxusRFMv1__survey__c, ArxxusRFMv1__survey__r.Audit_PDF_Section_Name__c, ArxxusRFMv1__survey__r.Have_different_name_in_PDF__c,
                                                              (SELECT Id,ArxxusRFMv1__answer__c,ArxxusRFMv1__question__c,ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__Survey__c,ArxxusRFMv1__questionDefinition__c,
                                                                ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__value__c,ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__fieldType__c,
                                                                ArxxusRFMv1__Task_Survey_Answer__c, ArxxusRFMv1__questionDefinition__r.Does_this_question_has_a_description__c,
                                                                ArxxusRFMv1__questionDefinition__r.Question_Description__c, ArxxusRFMv1__Answer_Index__c, Detailed_Findings__c,
                                                                ArxxusRFMv1__taskSurvey__c, ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__Survey__r.Have_different_name_in_PDF__c,
                                                                ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__Survey__r.Audit_PDF_Section_Name__c, 
                                                               	ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__Custom_Question_Number__c, 
                                                                ArxxusRFMv1__questionDefinition__r.Is_Display_Question_Number__c,
                                                               	ArxxusRFMv1__Question_Values__c,
                                                                ArxxusRFMv1__questionDefinition__r.Custom_Section_Sub_header__c, CreatedDate
                                                                FROM ArxxusRFMv1__storeSurveyAnswers__r
                                                                ORDER BY ArxxusRFMv1__Answer_Index__c)
                                                    FROM ArxxusRFMv1__taskSurvey__c WHERE Id IN : taskSurveyIdList AND ArxxusRFMv1__survey__c != null
                                                    ORDER BY ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c]) {
        
            System.debug('tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r**** : '+tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r);                                         
            auditSectionNames.add(tskSurvey.ArxxusRFMv1__task__r.Name);
            
            if(tskSurvey.ArxxusRFMv1__task__r.Name == AUDIT_FINDINGS
                || tskSurvey.ArxxusRFMv1__task__r.Name == INITIAL_FINDINGS
                || tskSurvey.ArxxusRFMv1__task__r.Name == FINAL_NOTES_AND_COMMENTS) {
                
                for(ArxxusRFMv1__taskSurveyAnswer__c tempAnswer : tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r) {
                   
                    if(tempAnswer.ArxxusRFMv1__Task_Survey_Answer__c == NULL) {
                    
                        List<String> existingList = auditSectionNamesMap.get('1-Initial Findings (Closing Meeting)');
                        existingList.add(tempAnswer.ArxxusRFMv1__question__c.replace('Completed', ''));
                        auditSectionNamesMap.put('1-Initial Findings (Closing Meeting)', existingList);
                    
                        existingList = auditSectionNamesMap.get('4-Detailed Findings');
                        existingList.add(tempAnswer.ArxxusRFMv1__question__c.replace('Completed', ''));
                        auditSectionNamesMap.put('4-Detailed Findings', existingList);
                    }
                }
            }
            else if(tskSurvey.ArxxusRFMv1__task__r.Name == AUDITORS_DECLARATION
                || tskSurvey.ArxxusRFMv1__task__r.Name == SERVICE_PROVIDER_SIGNATURE) {
              
                    List<String> existingList = auditSectionNamesMap.get('1-Initial Findings (Closing Meeting)');
                    existingList.add(tskSurvey.ArxxusRFMv1__task__r.Name);
                    auditSectionNamesMap.put('1-Initial Findings (Closing Meeting)', existingList);
            }
            else {
                    
                    List<String> existingList = auditSectionNamesMap.get('3-Audit Questions');
                    String surveyName = tskSurvey.ArxxusRFMv1__survey__r.Have_different_name_in_PDF__c ? tskSurvey.ArxxusRFMv1__survey__r.Audit_PDF_Section_Name__c : tskSurvey.ArxxusRFMv1__task__r.Name;
                    existingList.add(surveyName);
                    auditSectionNamesMap.put('3-Audit Questions', existingList);
            }
              
            if(tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r == null || tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r.isEmpty()) {
                
                System.debug('In********Surv');
                continue;
            }
            if(!taskSurveyVsSurveyAnswers.containsKey(tskSurvey.Id)) {
                
                taskSurveyVsSurveyAnswers.put(tskSurvey.Id,tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r);
            }
            else {              
                
                taskSurveyVsSurveyAnswers.get(tskSurvey.Id).add(tskSurvey.ArxxusRFMv1__storeSurveyAnswers__r);
            }
        }
        System.debug('taskSurveyVsSurveyAnswers****** : '+taskSurveyVsSurveyAnswers);
    }
    
    private void populateDateFromSurveyQuestion() {
       
        surveyQuestionVsIndex = new Map<String,Decimal>();
        for(ArxxusRFMv1__surveyQuestion__c surveyQuestion : [SELECT Id, ArxxusRFMv1__survey__c, ArxxusRFMv1__questionDefinition__c, ArxxusRFMv1__Index__c
                                                            FROM ArxxusRFMv1__surveyQuestion__c 
                                                            Where ArxxusRFMv1__survey__c IN : surveyId]) {
        
            String mapKey = String.valueOf(surveyQuestion.ArxxusRFMv1__survey__c)+String.valueOf(surveyQuestion.ArxxusRFMv1__questionDefinition__c);
            surveyQuestionVsIndex.put(mapKey,surveyQuestion.ArxxusRFMv1__Index__c);
        }

    }
    
    //Method will be called From Batch Class In-order to process visits
    public void sendRecords(String visitId,Map<String,List<String>> visitVsTaskSurveys,
                            Map<String,List<ArxxusRFMv1__taskSurveyAnswer__c>> taskSurveyVsSurveyAnswers) {
        
        System.debug('taskSurveys*** : '+visitVsTaskSurveys.get(visitId));                                                                                       
        Map<String, ArxxusRFMv1__taskSurvey__c> taskSurveyIdVsTaskSurvey 
                                                = new Map<String,ArxxusRFMv1__taskSurvey__c>([SELECT Id, Name, ArxxusRFMv1__survey__r.Name,ArxxusRFMv1__task__r.ArxxusRFMv1__Reason_For_Incompletion__c,
                                                                                                ArxxusRFMv1__survey__r.ArxxusRFMv1__Instructions__c,
                                                                                                ArxxusRFMv1__survey__r.Audit_PDF_Section_Name__c, ArxxusRFMv1__survey__r.Have_different_name_in_PDF__c,
                                                                                              	ArxxusRFMv1__survey__r.Survey_Section_Number__c  
                                                                                              	From ArxxusRFMv1__taskSurvey__c
                                                                                                WHERE ID IN :visitVsTaskSurveys.get(visitId)]);
        
        taskSurveys = new List<taskSurveyData>();
        initialFindingsTaskSurveys = new List<taskSurveyData>();
        detailedFindingsTaskSurveys = new List<taskSurveyData>();
                                
        for(String taskId : visitVsTaskSurveys.get(visitId)) {
            
            taskSurveyData tempTskSurvey = new taskSurveyData();
            tempTskSurvey.taskId = taskId;
            tempTskSurvey.taskSubject = taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.Have_different_name_in_PDF__c ? taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.Audit_PDF_Section_Name__c : taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.Name;           
            tempTskSurvey.sectionNumber = taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.Survey_Section_Number__c == NULL ?
                '' : String.valueOf(taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.Survey_Section_Number__c);
            tempTskSurvey.renderedTask = false;
            tempTskSurvey.renderedReasonBlock = false;
            tempTskSurvey.instruction = taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__survey__r.ArxxusRFMv1__Instructions__c;
            if(tempTskSurvey.instruction != null) {
                
                tempTskSurvey.renderedInstruction = true;
            }
            else {
                
                tempTskSurvey.renderedInstruction = false;
            }
            List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswersForTask = taskSurveyVsSurveyAnswers.get(taskId);
            List<taskSurveyAnswerData> tempSurveyAns = new List<taskSurveyAnswerData>();
            if((taskSurveyAnswersForTask != null) && (!taskSurveyAnswersForTask.isEmpty())) {
                
                tempSurveyAns = prepareParentChildWrapper(taskSurveyAnswersForTask);    
            }            
            if((tempSurveyAns != null) && (!tempSurveyAns.isEmpty())) {
               
                tempTskSurvey.taskSurveyAnswers = arrangeQuestionsInOrder(tempSurveyAns);
                tempTskSurvey.renderedTask = true;
            }
            if(taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__task__r.ArxxusRFMv1__Reason_For_Incompletion__c != null) {
                
                tempTskSurvey.renderedTask = true;
                tempTskSurvey.reasonForInComplete = taskSurveyIdVsTaskSurvey.get(taskId).ArxxusRFMv1__task__r.ArxxusRFMv1__Reason_For_Incompletion__c;
                tempTskSurvey.renderedReasonBlock = true;
            }             
            //tempTskSurvey.taskSurveyAnswers = prepareParentChildWrapper(taskSurveyAnswersForTask);
            System.debug('tempTskSurvey****** : '+tempTskSurvey);
            
            if(tempTskSurvey.taskSubject == AUDIT_FINDINGS
                || tempTskSurvey.taskSubject == INITIAL_FINDINGS
                || tempTskSurvey.taskSubject == AUDITORS_DECLARATION
                || tempTskSurvey.taskSubject == SERVICE_PROVIDER_SIGNATURE
                || tempTskSurvey.taskSubject == FINAL_NOTES_AND_COMMENTS)
                initialFindingsTaskSurveys.add(tempTskSurvey);
            else
                taskSurveys.add(tempTskSurvey);
            
            //for displayig detailed findings section
            if(tempTskSurvey.taskSubject == AUDIT_FINDINGS
                || tempTskSurvey.taskSubject == INITIAL_FINDINGS
                || tempTskSurvey.taskSubject == FINAL_NOTES_AND_COMMENTS) {

                detailedFindingsTaskSurveys.add(tempTskSurvey);
            }
        }
        
        //calculateTotalScore(taskSurveyIdVsTaskSurvey);
        System.debug('taskSurveysList **** : '+taskSurveys);
    }
    
    private List<taskSurveyAnswerData> prepareParentChildWrapper(List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswersForTask) {

        System.debug('taskSurveyAnswersForTask*********** : '+taskSurveyAnswersForTask);
        List<taskSurveyAnswerData> parentTaskSurveyAns = new List<taskSurveyAnswerData>();
        parentVsChildMap = new Map<String,taskSurveyAnswerData>();
        List<taskSurveyAnswerData> finalSurveyAnsList = new List<taskSurveyAnswerData>();
        Integer counter = 0;
        for(ArxxusRFMv1__taskSurveyAnswer__c taskSurveyAnsObj : taskSurveyAnswersForTask) {
            
            taskSurveyAnswerData tempParentSurveyAns = new taskSurveyAnswerData();
            
            tempParentSurveyAns.customQuestionNumber = taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__Custom_Question_Number__c;

            tempParentSurveyAns.isDisplayQuestionNumber =  taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.Is_Display_Question_Number__c;
            
            tempParentSurveyAns.customSectionSubHeader = taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.Custom_Section_Sub_header__c;

            if(taskSurveyAnsObj.ArxxusRFMv1__Question_Values__c != null){
                tempParentSurveyAns.questionValues = taskSurveyAnsObj.ArxxusRFMv1__Question_Values__c.split(',');
            }
            
            tempParentSurveyAns.questionText = taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.Does_this_question_has_a_description__c ? taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.Question_Description__c : taskSurveyAnsObj.ArxxusRFMv1__question__c;
            if(taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__fieldType__c == 'Date') {
                tempParentSurveyAns.answer = formatDate(taskSurveyAnsObj.ArxxusRFMv1__answer__c);
            }
            else if(taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__fieldType__c == 'Date & Time') {
                tempParentSurveyAns.answer = formatDateTime(taskSurveyAnsObj.ArxxusRFMv1__answer__c);
            }
            else {
                tempParentSurveyAns.answer = taskSurveyAnsObj.ArxxusRFMv1__answer__c;   
            }
            tempParentSurveyAns.detailedFindingAnswer = taskSurveyAnsObj.Detailed_Findings__c;
            tempParentSurveyAns.createdDate = taskSurveyAnsObj.CreatedDate.format('dd/MM/YYYY'); 
            
            tempParentSurveyAns.answerFieldType = taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__fieldType__c;
            
            System.debug('Detailed Finding Ans: '+taskSurveyAnsObj.Detailed_Findings__c);
            
            tempParentSurveyAns.isParentAnswer = taskSurveyAnsObj.ArxxusRFMv1__Task_Survey_Answer__c == NULL ? TRUE : FALSE;
            tempParentSurveyAns.questionOptions = new List<String>();

            String options = taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__r.ArxxusRFMv1__value__c;

            if(options != null) {

                List<String> optionList = options.split(',');

                for(String eachOption : optionList) {
                    tempParentSurveyAns.questionOptions.add(eachOption.trim());
                }

                tempParentSurveyAns.renderFlag = false;
            }
            else {
                tempParentSurveyAns.renderFlag = true;
            }

            if(taskSurveyAnsObj.ArxxusRFMv1__Task_Survey_Answer__c == null) {

                tempParentSurveyAns.selfId = taskSurveyAnsObj.Id;

                tempParentSurveyAns.surveyId = taskSurveyAnsObj.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__Survey__c;
                tempParentSurveyAns.questionId =  taskSurveyAnsObj.ArxxusRFMv1__questionDefinition__c; 
                String key = tempParentSurveyAns.surveyId+tempParentSurveyAns.questionId;
                tempParentSurveyAns.indexVal = Integer.valueOf(surveyQuestionVsIndex.get(key));

                parentTaskSurveyAns.add(tempParentSurveyAns);
               
            }
            else {

                tempParentSurveyAns.selfId = taskSurveyAnsObj.Id;
                tempParentSurveyAns.parentId = taskSurveyAnsObj.ArxxusRFMv1__Task_Survey_Answer__c;
                parentVsChildMap.put(taskSurveyAnsObj.ArxxusRFMv1__Task_Survey_Answer__c,tempParentSurveyAns);
            }
            
        }

        return parentTaskSurveyAns;
    }
    
    private List<TaskSurveyData> populateAnswersImageId(List<TaskSurveyData> taskSurveysWrapper, Map<String, List<ArxxusRFMv1__TaskSurveyAnswer__c>> taskSurveyVsSurveyAnswers) {
        
        if(null != taskSurveysWrapper && !taskSurveysWrapper.isEmpty() 
            && null != taskSurveyVsSurveyAnswers && !taskSurveyVsSurveyAnswers.isEmpty()) {
            
            List<ArxxusRFMv1__TaskSurveyAnswer__c> allAnswers = new List<ArxxusRFMv1__TaskSurveyAnswer__c>();
            for(TaskSurveyData tsdWr :taskSurveysWrapper) {
                
                if(taskSurveyVsSurveyAnswers.containsKey(tsdWr.taskId)) {
                
                    allAnswers.addAll(taskSurveyVsSurveyAnswers.get(tsdWr.taskId));
                }
            }

            Map<String, Attachment> answerImagesMap = new Map<String, Attachment>();
            for(Attachment att : [Select Id, Name, ParentId, BodyLength From Attachment Where ParentId IN :allAnswers And ContentType like '%image%']) {
                answerImagesMap.put(att.ParentId, att);
            }
            System.debug('answerImagesMap JSON:' + JSON.serialize(answerImagesMap));

            Integer assignedImageSize = 0;
            for(TaskSurveyData tsdWr :taskSurveysWrapper) {
              
                if(null != tsdWr.taskSurveyAnswers && !tsdWr.taskSurveyAnswers.isEmpty()) {
                
                    for(TaskSurveyAnswerData tsAnsWr :tsdWr.taskSurveyAnswers) {
                    
                        if(String.isNotEmpty(tsAnsWr.selfId) && answerImagesMap.containsKey(tsAnsWr.selfId) && assignedImageSize < PDF_SIZE_LIMIT) {
                        
                            Attachment ansAtt = answerImagesMap.get(tsAnsWr.selfId);

                            tsAnsWr.imageId = ansAtt.Id;
                            tsAnsWr.displayImage = true;

                            assignedImageSize += ansAtt.BodyLength;
                        }
                    }
                }
            }      
        }

        System.debug('taskSurveysWrapper JSON:' + JSON.serialize(taskSurveysWrapper));
        System.debug('taskSurveys JSON:' + JSON.serialize(taskSurveys));

        return taskSurveysWrapper;
    }
    
    private List<taskSurveyAnswerData> arrangeQuestionsInOrder(List<taskSurveyAnswerData> unOrderedSurveyAnsDate) {
       
        List<taskSurveyAnswerData> orderedData = new List<taskSurveyAnswerData>();
        List<Integer> indexes = new List<Integer>();
        Map<String,taskSurveyAnswerData> compositeKeyVsSurveyAns = new Map<String,taskSurveyAnswerData>();
        Map<Integer,String> indexVsCompositeKey = new Map<Integer,String>();
        
        for(taskSurveyAnswerData tskSurveyObj : unOrderedSurveyAnsDate) {
        
            indexes.add(tskSurveyObj.indexVal);
            String key = tskSurveyObj.surveyId+tskSurveyObj.questionId;
            compositeKeyVsSurveyAns.put(key,tskSurveyObj);
            indexVsCompositeKey.put(tskSurveyObj.indexVal,key);
        }
        
        indexes.sort();
        
        for(Integer i : indexes) {
        
            String compositeKey = indexVsCompositeKey.get(i);
            taskSurveyAnswerData tempTskSurAns = compositeKeyVsSurveyAns.get(compositeKey);
            orderedData.add(tempTskSurAns);
            String parentKey = tempTskSurAns.selfId;
            
            while(parentVsChildMap.containsKey(parentKey)) {
            
                TaskSurveyAnswerData childTaskSurAns = parentVsChildMap.get(parentKey);
                orderedData.add(childTaskSurAns);
                parentVsChildMap.remove(parentKey);
                parentKey = childTaskSurAns.selfId;                
            }
        }
        
        return orderedData;
    }
    
    //This Method Will Date type of text to required date Format.
    @testVisible
    private String formatDate(String dateString) {
       
        Map <String, String> monthNames = new Map <String, String> {'Jan'=>'01', 'Feb'=>'02', 'Mar'=>'03', 'Apr'=>'04', 'May'=>'05', 'Jun'=>'06', 'Jul'=>'07', 'Aug'=>'08', 'Sep'=>'09', 'Oct'=>'10', 'Nov'=>'11', 'Dec'=>'12'};
        String dateVal;
        
        if(dateString != null && dateString != '') {
        
            String[] dateArray = dateString.split(' ');
            String mntVal = monthNames.get(dateArray[1]);
            String dayVal = dateArray[2];
            
            if(dayVal.length() < 2) {
                dayVal = '0'+dayVal;
            }
            
            String yearVal =  dateArray[3];
            dateVal = dayVal+'/'+mntVal+'/'+yearVal;
        }
        return dateVal;     
    }

    //Method will format dateTime text value to required date time String
    @testVisible
/*
    private String formatDateTime(String dateTimeString) {
        
        Map <String, String> monthNames = new Map <String, String> {'Jan'=>'01', 'Feb'=>'02', 'Mar'=>'03', 'Apr'=>'04', 'May'=>'05', 'Jun'=>'06', 'Jul'=>'07', 'Aug'=>'08', 'Sep'=>'09', 'Oct'=>'10', 'Nov'=>'11', 'Dec'=>'12'};
        String datetimeVal;
        
        if(dateTimeString != null && dateTimeString != '') {
        
             String[] dateTimeArray = dateTimeString.split(' ');
             String mntVal = monthNames.get(dateTimeArray[1]);
             String dayVal = dateTimeArray[2];
             
             if(dayVal.length() < 2) {
                dayVal = '0'+dayVal;
             }
             
             String yearVal =  dateTimeArray[3];
             String[] dateTimeValArray =  dateTimeArray[4].split(':');
             String hrsVal = dateTimeValArray[0];
             String minVal = dateTimeValArray[1];
             String avb = 'AM';
             Integer hrsIntVal = Integer.valueOf(hrsVal);
             
             if((hrsIntVal > 12) && (hrsIntVal != 0)) {
                 
                 hrsIntVal = hrsIntVal-12;
                 avb = 'PM';
                 hrsVal = String.valueOf(hrsIntVal);
             }
             else if(hrsIntVal == 0) {
             
                hrsVal = '12';
                hrsVal = String.valueOf(hrsVal);
             }
             
             if(hrsVal.length() < 2) {
                
                 hrsVal = '0'+hrsVal;
             }
             
             datetimeVal = dayVal+'/'+mntVal+'/'+yearVal+' '+hrsVal+':'+minVal+' '+avb;
        }
        return datetimeVal;
    }
    
    private List<taskSurveyData> updateDataForAuditSummaryPage(List<taskSurveyData> initialFindingsTaskSurveys) {
        
        Map<String, taskSurveyAnswerData> mapIDVSTaskSurveyAnswer = new Map<String, taskSurveyAnswerData>();
        Map<String, List<taskSurveyAnswerData>> mapParentVSChildTaskSurveyAnswers = new Map<String, List<taskSurveyAnswerData>>();
                
        for(taskSurveyData initialFindingsSurveyData : initialFindingsTaskSurveys) {
            
            mapIDVSTaskSurveyAnswer = new Map<String, taskSurveyAnswerData>();
            
            for(taskSurveyAnswerData taskSurveyAns : initialFindingsSurveyData.taskSurveyAnswers) {
                
                taskSurveyAns.questionText = taskSurveyAns.questionText.replace('Completed', '');
                mapIDVSTaskSurveyAnswer.put(taskSurveyAns.selfId, taskSurveyAns);
            }
            
            for(taskSurveyAnswerData taskSurveyAns : initialFindingsSurveyData.taskSurveyAnswers) {
                
                if(taskSurveyAns.parentId != NULL) {
                    
                    taskSurveyAnswerData parentTaskSurveyAnswerData = mapIDVSTaskSurveyAnswer.get(taskSurveyAns.parentId);
                    parentTaskSurveyAnswerData.answer = taskSurveyAns.answer;
                    
                    mapIDVSTaskSurveyAnswer.put(taskSurveyAns.parentId, parentTaskSurveyAnswerData);
                    mapIDVSTaskSurveyAnswer.remove(taskSurveyAns.selfId);
                }
            }
            
            initialFindingsSurveyData.taskSurveyAnswers = mapIDVSTaskSurveyAnswer.values();
        }
        
        return initialFindingsTaskSurveys;
    }
    
    //Wrapper Class which will hold task Data that needs to be rendered on VF Page
    public class taskSurveyData {
        
        public String taskSubject {get;set;}
        public String sectionNumber {get;set;}
        public List<taskSurveyAnswerData> taskSurveyAnswers {get;set;}
        public boolean renderedInstruction {get;set;}
        public boolean renderedTask {get;set;}
        public String instruction {get;set;}
        public String reasonForInComplete {get;set;}
        public boolean renderedReasonBlock {get;set;}
        public String taskId {get; set;}
    }
    
    //Wrapper Class which will hold surveyAnswer Data that needs to be rendered on VF Page
    public class taskSurveyAnswerData {
       
        public String selfId {get;set;}
        public String parentId {get;set;}
        public String questionText {get;set;}
        public String surveyId;
        public String questionId;
        public Integer indexVal;
        public List<String> questionOptions {get;set;}
        public String answer {get;set;} 
        public boolean renderFlag {get;set;}
        public String imageId {get;set;}
        public boolean displayImage {get;set;}
        public String detailedFindingAnswer {get;set;} 
        public boolean isParentAnswer  {get;set;}
        public String customQuestionNumber{get;set;}
        public List<String> questionValues{get;set;}
        public String answerFieldType{get;set;}
        public String customSectionSubHeader {get;set;}
        public boolean isDisplayQuestionNumber {get;set;}
        public List<String> multipleAnswers{get;set;}
        public String createdDate{get;set;}
        
        public taskSurveyAnswerData() {
            
            imageId = '';
            displayImage = false;
            detailedFindingAnswer = '';
        }
    }
    
    //Wrapper Class which will hold surveyAnswer Data that needs to be rendered on VF Page
    public class HeaderInfo {
        
        public String storeId {get;set;}
        public String description {get;set;}
        public String street {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String code {get;set;}
        public String country {get;set;}
        public String fullAddress {get;set;}
        public String actualStartDate {get;set;}
        public String actualEndDate {get;set;}
        public String auditName {get;set;}
        public String accountName {get;set;}
        public String accountABN {get;set;}
        public String accountRegisteredBusinessName {get;set;}
        public String contactName {get;set;}
        public String accountAuthDetails {get;set;}
        public String auditorName {get;set;}
        public String auditorAccount {get;set;}
        public String auditorPhone {get;set;}
        public String auditorEmail {get;set;}
        public String actualEndTime {get;set;}
        public String accountRecordKeepingAddress {get;set;}
        public String accountPhone {get; set;}
        public String accountEmail {get; set;}
        public String accountPostalAddress {get; set;}
        public String accountPostalAddressCode {get; set;}
        public String auditGroup {get; set;}
        public String accountBillingStreet {get; set;}
        public String accountBillingCity {get; set;}
        public String accountBillingState {get; set;}
        public String accountBillingPostalCode {get; set;}
        public String accountBillingCountry {get; set;}
        public String accountFax {get; set;}
        public String actualStartTime{get; set;}
        public String auditSubStatus{get; set;}
    }
*/
}
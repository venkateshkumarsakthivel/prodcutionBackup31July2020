public with sharing class GetAssessmentRequestController {
    
    private P2POSRGetAssessmentResponseParserVisitor p2POSRGetAssessmentResponseParserVisitor {get; set;}
    
    private static MAP<String,String> authTypeAndAmounts {get; set;}
    private static String currentAssessmentId {get; set;}
    private static String levyPeriodMonthName {get; set;}
    
    public GetAssessmentRequestController() {
        this.p2POSRGetAssessmentResponseParserVisitor = new P2POSRGetAssessmentResponseParserVisitor();
    }
    
    private static P2POSRClient.OSR_REQUEST_TYPE type() {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST;
    }
    @testvisible
    private static P2POSRRequestParameter createRequestParameter(String assessmentId) {
        
        String strQuery = 'SELECT Id, Name, Period_Start_Date__c, Period_End_Date__c, Account__r.Customer_Number__c, '
            + 'Taxpayer_Registration__r.Booking_Service_Provider_Number__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c '
            + 'FROM Assessment__c '
            + 'WHERE Id = :assessmentId ';
        
        System.debug(LoggingLevel.INFO, '== GetAssessmentRequestController Generated Query ==' + strQuery);
         
        // Get Assessment Record
        Assessment__c assessmentRecord = Database.query(strQuery);
        
        P2POSRAssessment assessmentForBspAuthorisation;
        P2POSRAssessment assessmentForTspAuthorisation;
        P2POSRAssessments p2POSRAssessments;
        P2POSRRequestParameter p2pOSRRequestParameter;
        
        Date reportingPeriodStartDate = assessmentRecord.Period_Start_Date__c;
        Date reportingPeriodEndDate = assessmentRecord.Period_End_Date__c;
        
        p2POSRAssessments = new P2POSRAssessments();
        
        // We can have two Authorisations TSP and BSP linked to TaxPayer associated with Assessment
        if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != NULL) {
            assessmentForTspAuthorisation = new P2POSRAssessment();
            assessmentForTspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
            assessmentForTspAuthorisation.regnType = 'TT';
            assessmentForTspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
            assessmentForTspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
            assessmentForTspAuthorisation.includeAllVersion = 'false';
            p2POSRAssessments.assessmentForTspAuthorisation = assessmentForTspAuthorisation;
        }
        
        if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != NULL) {
            assessmentForBspAuthorisation = new P2POSRAssessment();
            assessmentForBspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
            assessmentForBspAuthorisation.regnType = 'TB';
            assessmentForBspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
            assessmentForBspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
            assessmentForBspAuthorisation.includeAllVersion = 'false';
            p2POSRAssessments.assessmentForBspAuthorisation = assessmentForBspAuthorisation;
            
        }
        
        p2pOSRRequestParameter = new P2POSRRequestParameter();
        p2pOSRRequestParameter.p2pOSRAssessments = p2POSRAssessments;
        
        return p2POSRRequestParameter;
    }
    
    @AuraEnabled
    public static MAP<String,String> executeOSRGetAssessment(String assessmentId, String levyPeriodMonth) {
        P2POSRGetAssessmentResponseParserVisitor visitor;
        
        try {
           
            String currentUserProfile = UserInfo.getProfileId();
            Profile userProfile = [Select Name from Profile where Id =: currentUserProfile];
            
            if(!(userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3 || userProfile.Name == GlobalConstants.ADMIN_PROFILE_NAME)) 
            {
                 authTypeAndAmounts = new MAP<String,String>();
                 authTypeAndAmounts.put('isAccessible', 'false');
                 return authTypeAndAmounts;
            }
            
            currentAssessmentId = assessmentId;
       		levyPeriodMonthName = levyPeriodMonth;
            
            P2POSRRequestParameter p2pOSRRequestParameter = createRequestParameter(assessmentId);
            visitor = new P2POSRGetAssessmentResponseParserVisitor();
            P2POSRClient p2POSRClient = new P2POSRClient();
            
            //This will send the Request and return the response
            p2POSRClient.call(GetAssessmentRequestController.type(), visitor, p2POSRRequestParameter);
            
           	// Method to create map of reuired responses to send on Lightning Component
            GetAssessmentRequestController.finish(visitor.finalize());
            system.debug('before');
			return GetAssessmentRequestController.authTypeAndAmounts;
        } catch(Exception ex)  {
            System.debug(LoggingLevel.ERROR, '== GetAssessmentRequestController Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== GetAssessmentRequestController Exception ==' + ex.getStackTraceString());
        }        
        return null;
    }
    
    public static void finish(List<P2POSRGetAssessmentResponse> p2POSRGetAssessmentResponses) {
        
        system.debug('In get assessment finish...' + p2POSRGetAssessmentResponses);
        authTypeAndAmounts = new MAP<String,String>();
        String authType = '';
        Decimal totalAmountPayable = 0;
        Decimal totalAmountCollected = 0;
        Decimal netBalance = 0;
        Boolean isAssessmentResponseReceived = false;
        
        Datetime currentDateTime = System.now();
        String currentDateTimeFormatted = currentDateTime.format('dd-MMM-yyyy HH:mm');
        
        system.debug('cmp date >>' + currentDateTimeFormatted);
        authTypeAndAmounts.put('UserName', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        authTypeAndAmounts.put('CurrentDateTime', currentDateTimeFormatted);
        
        for(P2POSRGetAssessmentResponse p2POSRGetAssessmentResponse : p2POSRGetAssessmentResponses) {
           
            if(p2POSRGetAssessmentResponse.p2POSRAssessment.size() > 0) {
               
                isAssessmentResponseReceived = true;
                
                if(p2POSRGetAssessmentResponse.regnType == 'TT') {
                    authTypeAndAmounts.put('tspAssessedLiability', String.valueOf(p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountPayable));
                    authTypeAndAmounts.put('tspAmountReceived' , String.valueOf(p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountCollected));
                    totalAmountPayable += p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountPayable;
                    totalAmountCollected += p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountCollected;
                 } 
                else if(p2POSRGetAssessmentResponse.regnType == 'TB') {
                    authTypeAndAmounts.put('bspAssessedLiability', String.valueOf(p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountPayable));
                    authTypeAndAmounts.put('bspAmountReceived' , String.valueOf(p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountCollected));
                    totalAmountPayable += p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountPayable;
                    totalAmountCollected += p2POSRGetAssessmentResponse.p2POSRAssessment[0].amountCollected;
                 }
            }    
        }
        
        if(p2POSRGetAssessmentResponses.size() > 0 && isAssessmentResponseReceived == true) {
            
            netBalance = totalAmountPayable - totalAmountCollected;
            
            note noteOnAssessment = new note();
            noteOnAssessment.parentId= currentAssessmentId; //Id of the Assessment for which you want to add this note
            noteOnAssessment.title='Balance check requested by:'+ UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); // the title of the note
            
            currentDateTimeFormatted = currentDateTime.format('dd/MM/yyyy HH:mm:ss');
             system.debug('note date >>' + currentDateTimeFormatted);
            String bodyValue = 'Total levy payable for the month of '+ levyPeriodMonthName + ' : $' + totalAmountPayable + ', ';
            bodyValue += 'Balance check requested datetime ' + currentDateTimeFormatted +', ';
            bodyValue += 'Total levy collected for the month of ' + levyPeriodMonthName + ' : $' + totalAmountCollected + ', ';
            bodyValue += 'Net Balance : $' + netBalance;
            noteOnAssessment.body= bodyValue;
            
            noteOnAssessment.isPrivate=false;  // if private it will be visible only for the owner and any user with modify all permission
            insert noteOnAssessment; //insert the record*/
            
            system.debug('Id of note >>>>' + noteOnAssessment.Id);
        }
        system.debug('Map...' + authTypeAndAmounts);
    }   
   
}
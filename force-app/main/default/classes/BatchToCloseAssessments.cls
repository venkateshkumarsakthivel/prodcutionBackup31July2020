global class BatchToCloseAssessments implements Database.Batchable<sObject> {
    
    global final String query;
    global Set<String> OPEN_PENDING_STATUSES = new Set<String>{'Error','Closed','Outstanding','Superseded'};
    global final Integer T_PLUS_5_DAYS = 5;
    global BatchToCloseAssessments() {
        
        query = 'SELECT Id, Status__c, Payment_Due_Date__c FROM Assessment__c '+
            	'WHERE Is_Closed__c = FALSE AND Status__c IN : OPEN_PENDING_STATUSES';
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {
        
        final String STATUS_ERROR = 'Error';
        final String STATUS_CLOSED = 'Closed';
        final String STATUS_OUTSTANDING = 'Outstanding';
        final String STATUS_SUPERSEDED = 'Superseded';
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        BusinessHours nswBusinessHours = [SELECT Id, MondayStartTime, MondayEndTime 
                                          FROM BusinessHours 
                                          WHERE isDefault = true];
        
        for(Assessment__c assessment : scope) {
            if(assessment.Status__c == STATUS_ERROR || assessment.Status__c == STATUS_CLOSED || 
               assessment.Status__c == STATUS_SUPERSEDED ||
               isOutstanding5BusinessDays(assessment.Payment_Due_Date__c, nswBusinessHours)){
            	assessment.Is_Closed__c = true;
                assessmentList.add(assessment);
            } 
        }
        try{
           	Database.update(assessmentList, false);
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage('Error','BatchToCloseAssessments','execute',ex.getMessage(),ex);
        }
        
        
    }
    private Boolean isOutstanding5BusinessDays(Date dueDate, BusinessHours bhr) {
        Date dueDatePlus5 = GlobalUtility.retrieveBusinessDay(dueDate, T_PLUS_5_DAYS, bhr);
        if(dueDatePlus5 < System.today()) {
            return true;
        }
        return false;        
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}
/**
* Server side rest resource controller for Take Ownership custom quick action on case
*/
public with sharing class EscalatetoComp {
    
    @AuraEnabled
    public static String getNewOwnerName(String queueName) { 
        
        //Id userId = UserInfo.getUserId();
        Group queueId = [SELECT Name from Group where Type = 'Queue' AND DeveloperNAME =:queueName limit 1];
        
        System.debug('queueId: ' + queueId.name);
        return queueId.name;
    }
    
    //method which assigns ownership of case to logged in user 
    //and updates sub-status values accordingly
    @AuraEnabled
    public static String takeOwnership(String caseId,String queueName) { 
        List<Case> caseList = new List<Case>();
        string loggedInUserId = UserInfo.getUserId();
        
        String queueId = [SELECT Id from Group where Type = 'Queue' AND DeveloperNAME =:queueName].Id;
        try {
            for(Case c:[SELECT Id,Status,Sub_Status__c,OwnerId FROM Case WHERE Id = :caseId]){
                
                if(c.ownerid!=loggedInUserId) {
                return 'Invalid Operation';  
                    
               }
                    if(c.Status == 'New' || c.status=='In Progress'){
                        
                        if(queueName=='Compliance') {
                            c.Sub_Status__c = 'Escalated to Compliance';
                            c.Status= 'In Progress';
                            c.OwnerId=queueId;
                            caseList.add(c);
                        }
                        else if(queueName=='Sanctions_Level_2' )  {
                            c.Sub_Status__c = 'Escalated to Sanctions';
                            c.Status= 'In Progress';
                            c.OwnerId=queueId;
                            caseList.add(c);
                            
                        }
                        else if(queueName=='Service_Delivery'){
                            c.Sub_Status__c = 'Referred to Service Delivery';
                            c.Status= 'In Progress';
                            c.OwnerId=queueId;
                            caseList.add(c);  
                            
                        }
                        
                    }
                
              
            } 
            
            if(caseList.size() > 0){
                update caseList; 
                return 'SUCCESS';
            }
            else
                return 'ERROR';
        }                
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'EscalatetoCompController','EscalatetoComp',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
}
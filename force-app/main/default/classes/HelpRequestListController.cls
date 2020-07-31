/**
 * Manage List of Cases (Help Requests) 
 * from p2p community
 * 
 */
public class HelpRequestListController {

    public class HelpRequestException extends Exception{}
    
    //returns list of cases having record type 'Help request'.
    @AuraEnabled
    public static List<Case> getAllHelpRequests(){
     	List<Case> hrs;
        try{
            hrs = [SELECT Id, Subject, Description, CaseNumber, 
                   		Priority, Status, type, Owner.Name, CreatedDate 
                   FROM Case WHERE RecordType.Name = 'Help Request'
                  ORDER By CaseNumber desc];
        }catch(Exception ex){
            throw new HelpRequestException('Error fetching all help requests');
        }
        return hrs;
    }
    
    //insert case of record type 'Help request'
    @AuraEnabled
    public static String submitHelpRequest(String subject, String description, String type){
        String caseNumber;
        try{
			User user = [SELECT Id, Contact.Id, Contact.AccountId, Contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()];             
            Case hRequest = new Case();
            hRequest.Subject = subject;
            hRequest.Description = description;
            System.debug('Case Data = [' + subject + '],['  + description + ']');
            hRequest.Priority = 'Medium';
            hRequest.ContactId = User.Contact.Id;
            hRequest.Status = 'New';
            hRequest.Type = type;
            hRequest.AccountId = user.Contact.AccountId;
            
            insert hRequest;
            
            Case submittedRequest = [SELECT Id, CaseNumber FROM Case WHERE Id = :hRequest.Id LIMIT 1];
            caseNumber = submittedRequest.CaseNumber;
        }catch(Exception ex){
            //throw new HelpRequestException('Error creating a new help request.', ex);
			throw ex;
        }
        return caseNumber + ' - ' + subject + ' - ' + description;
    }
    
}
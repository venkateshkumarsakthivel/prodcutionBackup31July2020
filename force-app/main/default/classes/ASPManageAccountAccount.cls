// This class is used to manage all operations related to his/her account
public class ASPManageAccountAccount {
    public class BaseException extends Exception {}
    
    /*This function retrives Account details logged in user in string format. */
    @AuraEnabled
    public static String getAccountDetails(String requiredAccId){
        
        try{
        
            User user = GlobalUtility.getLoggedInUser();
            
            ID accID;
            
            if(String.isBlank(requiredAccId))
             accID = user.AccountId;
            else {
            
             accID = requiredAccId;
             
             if(GlobalUtility.agentHasAccountAccess(accID) == FALSE)
               return GlobalConstants.UNAUTHORISED_ACCESS;
            }
            
            String str = TaxiAgentDataAccessProvider.getAccountDataForAgents(accID);
            
            System.debug('String account: '+str);
            
            return str;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAccount','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    /*This function Updates account record according to user inputs. */
    @AuraEnabled
    public static Void saveAccountDetails(Id accId, String Bstreet, String Bcity, String Bstate, String Bpostcode, String Sstreet, String Scity, String Sstate, String Spostcode){
        try{
            if(accId != null){
                Account acc = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id =: accId];
                acc.BillingStreet = Bstreet;
                acc.BillingCity = Bcity;
                acc.BillingState = Bstate;
                acc.BillingPostalCode = Bpostcode;
                acc.ShippingStreet = Sstreet;
                acc.ShippingCity = Scity;
                acc.ShippingState = Sstate;
                acc.ShippingPostalCode = Spostcode;
                update acc;
            }
            else{
                throw new BaseException();
            }
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAccount','saveAccountDetails',ex.getMessage(),ex);
        }
    }
    
    /*This function Creates case of help request if user updates his/her address. */
    @AuraEnabled
    public static String updateAccount(String actString){
        
        try{
            
            Account acc = (Account) JSON.deserialize(actString, Account.class);
            Account existingAcc = [SELECT Id, BillingCity, BillingState, BillingStreet, 
                                   ShippingCity,  ShippingState, ShippingStreet 
                                   FROM Account WHERE ID = :acc.Id];
            
            if(acc != null) {
            
                update acc;
                
                //if change in registered business address or record keeping address, create case for commissioner staff
                if((acc.BillingStreet != existingAcc.BillingStreet
                    || acc.BillingCity != existingAcc.BillingCity
                    || acc.BillingState != existingAcc.BillingState
                    || acc.ShippingStreet != existingAcc.ShippingStreet
                    || acc.ShippingCity != existingAcc.ShippingCity
                    || acc.ShippingState != existingAcc.ShippingState) && GlobalUtility.getLoggedInUser().Profile.Name != GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME) {
                       
                       submitHelpRequest();
                }
                
                return 'SUCCESS';
            }
            else{
            
                throw new BaseException();
                return 'ERROR';
            }
        } 
        catch (Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAccount','updateAccount',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    /*Helper function to updateAccount function. */
    public static void submitHelpRequest(){        
       
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SUPPORT_REQUEST_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = devRecordTypeId;
            caseRecord.AccountId = user.Contact.AccountId;
            caseRecord.ContactId = user.ContactId;
            caseRecord.Status = GlobalConstants.CASE_NEW;
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            caseRecord.setOptions(dmo);
            insert caseRecord;  
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAccount','submitHelpRequest',ex.getMessage(),ex);
        } 
        
    }
}
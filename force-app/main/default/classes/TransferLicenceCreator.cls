/*
 * @Description: Helper class to create a cloned version of licence been transferred.
 */
public with sharing class TransferLicenceCreator {

    private Case transferApplication;

    public TransferLicenceCreator(Case transferApplication){
        if(transferApplication == null || transferApplication.Id == null){
            throw new InvalidDataException('Failed to create licence record for transfer. Application details missing');
        }
        this.transferApplication = transferApplication;
    }

    public Authorisation__c create(){
        String soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c','id=\''+transferApplication.Authorisation__c+'\'');    
        
        //retrieve details of existing licence been transferred
        Authorisation__c auth = (Authorisation__c)Database.query(soql);
        
        //create a new copy of transfer licence
        Authorisation__c transferredLicence = auth.clone(false, true, false, false);
        transferredLicence.Status__c = GlobalConstants.AUTHORISATION_STATUS_NEW;
        transferredLicence.Service_Provider__c = transferApplication.AccountId;
        transferredLicence.Contact__c = transferApplication.ContactId;
        transferredLicence.OwnerId = UserInfo.getUserId();
        transferredLicence.Application__c = transferApplication.Id;
        transferredLicence.ASP_Authorisation_Approved__c = false;
        transferredLicence.Variation_Auth_Id__c = transferApplication.Authorisation__c;
        transferredLicence.Auto_Generate_Number__c = false;
        transferredLicence.Bank_Account_Name__c = null;
        transferredLicence.Bank_Account_Number__c = null;
        transferredLicence.BSB_Number__c = null;
        transferredLicence.Decision_Date__c = null;
        transferredLicence.Decision_Made_By__c = null;
        transferredLicence.Decision_Reason__c = null;
        transferredLicence.Is_Renewal_Licence__c = false;
        transferredLicence.Is_Transferred_Authorisation__c = true;
        transferredLicence.Related_Authorisation__c = transferApplication.Authorisation__c;
        transferredLicence.Renewal_Requested__c = false;
        transferredLicence.Renewal_Review_Needed__c = false;
        transferredLicence.Request_Type__c = null;
        transferredLicence.Return_Requested__c = false;
        transferredLicence.Support_Process_Approval_Status__c = null;
        transferredLicence.Status_Before_Approval__c = null;
        transferredLicence.SNSW_Plate_Pickup_Location__c = null;
        
         // Modified on 15 Nov 2019 : P2PSUPPORT-255 : Expected Transfer process : Removing the Agency association, since it is old one.
        if(transferApplication.Agent__c == Null){ 
        	transferredLicence.Agency__c = Null;
        }else{
            transferredLicence.Agency__c = transferApplication.Agent__c ;
        }
        
        //Added for overwritting Authorisation Name and Service Provider Notice Email on Authorisation.
        transferredLicence.Service_Provider_Notice_Email__c = transferApplication.Account.Notice_Email__c;
        transferredLicence.Authorisation_Name__c = transferApplication.Account.Name;
        
        // Insert Authorisation
        insert transferredLicence;
        
        return transferredLicence;
    }
    
    public class InvalidDataException extends Exception {}

}
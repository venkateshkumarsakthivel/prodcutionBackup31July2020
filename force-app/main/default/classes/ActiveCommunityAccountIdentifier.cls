/*
 * @Description: Helper class to identify the active/inactive community account
 */
public with sharing class ActiveCommunityAccountIdentifier {

    private List<Id> accIds;
    private Set<Id> activeAccounts;
    private Set<Id> inactiveAccounts;
    private List<User> portalUsers;
    private Boolean checkPerformed;
    
    public ActiveCommunityAccountIdentifier(List<Id> accIds){
        if(accIds == null){
            throw new InvalidDataException('Failed to identify active community account. Account details missing');
        }
        this.accIds = accIds;
        this.activeAccounts = new Set<Id>();
        this.inactiveAccounts = new Set<Id>(accIds);
        this.portalUsers = new List<User>();
        this.checkPerformed = false;
    }
    
    private void performCheck(){
        if(!checkPerformed){
            //retrieve all active users on an account.
            System.debug(LoggingLevel.INFO, 'All accounts ' + accIds);
            for(User portalUser : [ SELECT Id, AccountId, ProfileId FROM User 
                                    WHERE AccountId IN :accIds AND IsActive = true]) {
                if(inactiveAccounts.contains(portalUser.AccountId)){
                    inactiveAccounts.remove(portalUser.AccountId);  
                }
                activeAccounts.add(portalUser.AccountId);
                portalUsers.add(portalUser);
            }
            System.debug(LoggingLevel.INFO, 'Inactive accounts ' + inactiveAccounts);
            System.debug(LoggingLevel.INFO, 'Active accounts ' + activeAccounts);
            System.debug(LoggingLevel.INFO, 'Portal Users ' + portalUsers); 
        }       
    }
    
    public  Set<Id> retrieveActiveAccounts(){
        performCheck();     
        return activeAccounts;
    }
    
    public Set<Id> retrieveInactiveAccounts(){
        performCheck();     
        return inactiveAccounts;
    }
    
    public List<User> retrievePortalUsers(){
        performCheck();     
        return portalUsers;
    }
    
    public class InvalidDataException extends Exception {}
}
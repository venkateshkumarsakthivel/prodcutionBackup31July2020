@isTest
public class NetworkMemberHandlerTest {
    
    @isTest
    private static void NetworkMemberHandlerTestMethod() {
        
        Map<Id, NetworkMember> newNetworkMembers = new Map<Id,NetworkMember>();
        Map<Id,Network> networkdetails = new Map<Id,Network>();
        
        List<NetworkMember> objNetworkMemberList = GlobalUtility.getNetworkMemberList();
        for(NetworkMember NetworkMember : objNetworkMemberList){
            newNetworkMembers.put(NetworkMember.Id,NetworkMember);
            
        }
        Test.startTest();
        NetworkMemberTriggerHandler.afterInsert(newNetworkMembers);
        //NetworkMemberHandler objNetworkMemberUpdated = new NetworkMemberHandler(newNetworkMembers);   
        //objNetworkMemberUpdated.updatePreferencesDisableAllFeedsEmail();   
        Test.stopTest();
    }
}
public class NetworkMemberTriggerHandler {
    
     public static void afterInsert(Map<Id, NetworkMember> newNetworkMembers) {
        NetworkMemberHandler NetworkMemberUpdated = new NetworkMemberHandler(newNetworkMembers);
        NetworkMemberUpdated.updatePreferencesDisableAllFeedsEmail();
    }

}
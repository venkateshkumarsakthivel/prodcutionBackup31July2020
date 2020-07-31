/* CreatedBy: Srikanth Sunkara
* Created date: 18/05/2020
* Class : NetworkMemberHandler- Class to update PreferencesDisableAllFeedsEmail flag on Networkmember record to disable the 
* chatter notification for external(community) users.
Test Class: NetworkMemberHandlerTest
*/

public without sharing class NetworkMemberHandler {
    private Map<Id, NetworkMember> newNetworkMembers;
    private Map<Id,Network> networkdetails = new Map<Id,Network>();
    List<NetworkMember> networkMemberList = new List<NetworkMember>();
    public NetworkMemberHandler(Map<Id, NetworkMember> newNetworkMembers){
        
        this.newNetworkMembers = newNetworkMembers;
    }
    
    public void updatePreferencesDisableAllFeedsEmail() {    
        
        try {
            
            List<Network> networkList = [select Id, Name from Network where Name in ('Industry Portal','Taxi Licence') and status='Live'];
            for(Network nw : networkList)
            {
                networkdetails.put(nw.Id, nw);
            }
            
            
            for (NetworkMember networkmem : newNetworkMembers.values()){
                system.debug(networkmem.NetworkId);
                system.debug(networkdetails.get(networkmem.NetworkId).Id);
                if(networkmem.NetworkId == networkdetails.get(networkmem.NetworkId).Id){
                    NetworkMember updaterecord = new NetworkMember(Id=networkmem.Id);
                    updaterecord.PreferencesDisableAllFeedsEmail = true;
                    networkMemberList.add(updaterecord);
                }
            }
            if(networkMemberList.Size() > 0)
                update networkMemberList;
            
            System.debug('Network member Result: '+networkMemberList);
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NetworkMemberHandler','updatePreferencesDisableAllFeedsEmail',ex.getMessage(),ex);                        
        }
    } 
}
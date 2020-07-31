public with sharing class AttachmentTriggerHandler {

    //before delete handler
    public static void beforeDelete(Map<Id, Attachment> oldAttachments){
        if(GlobalUtility.ALLOW_FILE_DELETE){
            return;
        }
        
        //set to store names of profiles which can delete attachments
        Set<String> deletionAllowedProfileNames = new Set<String>();
        
        //fetching names of profiles configure in metadata Attachment_Deletion_Allowed_Profile__mdt
        List<Attachment_Deletion_Allowed_Profile__mdt> deletionAllowedProfiles = [SELECT DeveloperName, Label
                                                                                  FROM Attachment_Deletion_Allowed_Profile__mdt];
        
        System.debug('List: '+deletionAllowedProfiles);
        
        //storing names of profiles which can delete attachments
        for(Attachment_Deletion_Allowed_Profile__mdt tempAllowedProfile : deletionAllowedProfiles)
            deletionAllowedProfileNames.add(tempAllowedProfile.Label);
        
        //logged in user's profile
        String currentUserProfile = [SELECT User_Profile_Name__c 
                                     FROM User
                                     WHERE Id = :UserInfo.getUserId()].User_Profile_Name__c;
        
        System.debug('Current Users Profile: '+currentUserProfile);
        
        //if current user's profile is prohibited for deleting attachments
        if(deletionAllowedProfileNames.contains(currentUserProfile) == false) {
        
         //itrating over attachments which are initiated for deletion and preventing their deletion
         for(Attachment a : oldAttachments.values()) {
            
             a.addError('You do not have permission to delete attachments. Please contact System Administrator for more information.');
         }
        }
    }
}
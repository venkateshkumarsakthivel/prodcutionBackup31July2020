public with sharing class DeleteAttachmentEnabler {

    @InvocableMethod(label='Enable attachment deletion')
    public static void enableDelete(){
        GlobalUtility.ALLOW_FILE_DELETE = true;
    }
}
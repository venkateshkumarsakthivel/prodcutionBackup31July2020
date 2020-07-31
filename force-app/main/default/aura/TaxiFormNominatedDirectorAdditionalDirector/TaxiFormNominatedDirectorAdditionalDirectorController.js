({
    doInit : function(component, event, helper) {     
        console.log('In Additonal');
        if(component.get("v.applicantIdentityCheck") == true){
            console.log('poi document uploaded');
            component.set("v.directorPOIUploadStatus", true);
        } else {
            console.log('poi document not uploaded for additional director');
        }
    },
    performBlankInputCheck : function(component, event, helper) {
        console.log('In Additonal');
        helper.performBlankInputCheck(component, event, helper);
    }
})
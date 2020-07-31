({
    doInit : function(component, event, helper) {     
        
      	console.log('In Additonal');
        
      	console.log(component.get("v.nominatedDirectorActionInput"));
      	console.log(component.get("v.otherNameDetails"));
      	console.log(component.get("v.otherNameYes"));
      	console.log(component.get("v.otherNameNo"));
        console.log('applicantPOICheck: ' + component.get('v.applicantIdentityCheck'));
        console.log('police check' + component.get('v.applicantNationalPoliceCheck'));
        console.log('endorsementCheck' + component.get('v.applicantEndorsementCheck'));
        if(component.get('v.applicantIdentityCheck') == true){
            component.set('v.directorPOIUploadStatus', true);
        }
        if(component.get('v.applicantNationalPoliceCheck') == true){
            component.set('v.directorNationalPoliceUploadStatus', true);
        }
        if(component.get('v.applicantAppointmentCheck') == true){
            component.set('v.applicantAppointmentUploadStatus', true);
        }
        if(component.get('v.applicantEndorsementCheck') == true){
            component.set('v.directorEndorsementUploadStatus', true);
        }
        console.log('applicantAppointmentUploadStatus: ' + component.get('v.applicantAppointmentUploadStatus'));
        console.log('directorEndorsementUploadStatus: ' + component.get('v.directorEndorsementUploadStatus'));
        console.log('directorNationalPoliceUploadStatus: ' + component.get('v.directorNationalPoliceUploadStatus'));
        console.log('directorPOIUploadStatus: ' + component.get('v.directorCompanyExtractUploadStatus'));
    },
	otherNameChange : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "yes_notminatedDirector") {
            
            $A.util.removeClass(component.find("nominatedDirectorInputDetails"), "toggleDisplay");
            component.set("v.nominatedDirectorActionInput", true);
        }
        else {
            
            component.find("nominatedDirectorInputDetails").set('v.value', '');
            $A.util.addClass(component.find("nominatedDirectorInputDetails"), "toggleDisplay");
            component.set("v.nominatedDirectorActionInput", false);
            component.find("nominatedDirectorInputDetails").set("v.errors", null);
        }
    },
    performBlankInputCheck : function(component, event, helper) {
        
        console.log('In Child Controller');
        helper.performBlankInputCheck(component, event, helper);
    },
    roleChange : function(component, event, helper) {
        
        if(component.get("v.nominatedDirectorRole") == "Manager")
            component.set("v.displayEndorsementCheck", true);
        else
            component.set("v.displayEndorsementCheck", false);
        
        if(component.get("v.nominatedDirectorRole") != "")
            component.set("v.displayApplicantCriminalHistoryCheck", true);
        else
            component.set("v.displayApplicantCriminalHistoryCheck", false);
            
    }
})
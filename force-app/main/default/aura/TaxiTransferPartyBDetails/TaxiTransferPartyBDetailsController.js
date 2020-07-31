({
    doInit : function(component, event, helper) {
        console.log('initializing transfer details');
        // the function that reads the url parameters
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        component.set("v.caseId", getUrlParameter('appId'));
        helper.showSpinner(component, event);
        helper.loadSectionData(component, event, helper);         
    },
	
    toggleSectionContent : function(component, event, helper){        
        helper.toggleSectionContent(component, event);
    },
	
    fetchApplicationDetails : function(component, event, helper) {
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
			helper.loadSectionData(component, event, helper); 
    },
	
    closeApplication : function(component, event, helper) {
        window.location = "/taxilicence/s/manage-profile?src=accountMenu";
    },
	
    renderNextSection : function(component, event, helper) { 
        if(helper.performBlankInputCheck(component, event)) {         
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        } else {            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false);
        }
    },
	
    editCurrentSection : function(component, event, helper) {    
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
	
    cancelReviewEdit : function(component, event, helper) {
        document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';    
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);        
        helper.resetErrorMessages(component, event);
        helper.loadSectionData(component, event);
    },
	
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        } else {            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, true);
        }
    },
    setNoticeAddressType : function(component, event, helper) {        
        var selected = event.getSource().getLocalId();
        console.log("Selected"+selected);
        if(selected == "r1"){            
            component.set("v.noticeType", "Postal");
        }
        if(selected == "r0"){            
            component.set("v.noticeType", "Email");	
        }
    },
})
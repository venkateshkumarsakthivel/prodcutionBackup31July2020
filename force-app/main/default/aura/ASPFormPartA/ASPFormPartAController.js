({
    doInit : function(component, event, helper) {     
        
        console.log('doInit');
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
        console.log(sURLVariables.length);
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "appId" 
               && sParameterName[1] != "") {
                
                component.set("v.caseId", sParameterName[1]);
                appIdProvided = true;
            }
            
        }
        
        console.log(component.get('v.caseId'));
        
        helper.loadSectionData(component, event); 
        helper.toggleSectionContent(component, event);
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('Account Id Con: '+component.get("v.accountId"));
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
         helper.loadSectionData(component, event, helper); 
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    setLicenceType : function(component, event, helper){
        console.log(event.target.id);
        component.set("v.licenceType", event.target.id);
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false);
        }
        
    },
    renderPrevSection : function(component, event, helper) {
      
      if(component.get("v.accountId") != undefined && component.get("v.accountId") != "")   
        component.getEvent("closeApplication").fire();
      else if(component.get("v.applicationType") == "New" && component.get("v.applicationSource") == "PSP")
        window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
      else
        window.location = "/industryportal/s/manage-profile?src=accountMenu";   
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        
        if(component.get("v.businessIsAustralian")) {
         
            component.find("recordKeepingSameAsBusiness").set("v.disabled", false);
            component.find("noticeSameAsBusiness").set("v.disabled", false);
        }
        
        component.set("v.reviewEdit", true);
    }, 
    copyBusinessAddress : function(component, event, helper) {
        
        console.log('Inside address copy');
        
        if(component.get('v.isCopyAddress')){
            
            component.set("v.noticeStreet", component.get('v.businessStreet'));
            component.set("v.noticeCity", component.get('v.businessCity'));
            component.set("v.noticeState", component.get('v.businessState'));
            component.set("v.noticePostalCode", component.get('v.businessPostalCode'));
            component.set("v.noticeUnitType", component.get('v.businessUnitType'));
            component.find("Notice-Address").copySearchStringAddress();
        }
        else {
            
            component.set("v.noticeStreet", '');
            component.set("v.noticeCity", '');
            component.set("v.noticeState", '');
            component.set("v.noticePostalCode", '');
            component.set("v.noticeUnitType", '');
            component.find("Notice-Address").set("v.searchString", "");
        }
        console.log(component.get('v.noticeStreet'));
    },
    copyBusinessAddressToRecordKeeping : function(component, event, helper) {
        
        console.log('Inside address copy');
        
        if(component.get('v.isCopyAddressToRecordKeeping')){
            
            component.set("v.recordKeepingStreet", component.get('v.businessStreet'));
            component.set("v.recordKeepingCity", component.get('v.businessCity'));
            component.set("v.recordKeepingState", component.get('v.businessState'));
            component.set("v.recordKeepingPostalCode", component.get('v.businessPostalCode'));
            component.set("v.recordKeepingUnitType", component.get('v.businessUnitType'));
            
            component.find("Record-Keeping-Address").copySearchStringAddress();
        }
        else {
            
            component.set("v.recordKeepingStreet", '');
            component.set("v.recordKeepingCity", '');
            component.set("v.recordKeepingState", 'NSW');
            component.set("v.recordKeepingPostalCode", '');
            component.set("v.recordKeepingUnitType", '');
            component.find("Record-Keeping-Address").set("v.searchString", "");
        }
        console.log(component.get('v.recordKeepingUnitType'));
    },
    cancelReviewEdit : function(component, event, helper) {
        
        //$("#formPartA .slds-has-error").removeClass("slds-has-error");
        //$("#formPartA .slds-form-element__help").hide();
        document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        if(component.get("v.businessIsAustralian"))
         component.find("recordKeepingSameAsBusiness").set("v.disabled", true);
        
        if(component.get("v.noticeType") == "Postal") {
         component.find("noticeSameAsBusiness").set("v.disabled", true);
        }
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
        
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
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
            component.find("Notice-Email").set("v.isRequired", false); 
            
            if(component.find("Business-Address").get("v.isInternationalAddress"))
                component.find("noticeSameAsBusiness").set("v.disabled", true);
        }
        if(selected == "r0"){
            
            component.set("v.noticeType", "Email");	
            component.find("Notice-Email").set("v.isRequired", true); 
            
        }
    },
    handleBussinessAddressType : function(component, event, helper) {
        
        var bussinessAddressType = event.getParam("addressType");
        console.log("Bussiness Address Type Received: "+bussinessAddressType);
        
        if(bussinessAddressType == "International") {
            
            component.find("recordKeepingSameAsBusiness").set("v.disabled", true);
            component.set("v.isCopyAddressToRecordKeeping", false);
            component.set("v.recordKeepingStreet", '');
            component.set("v.recordKeepingCity", '');
            component.set("v.recordKeepingState", 'NSW');
            component.set("v.recordKeepingPostalCode", '');
            
            //component.set("v.businessIsAustralian", false);
            //component.set("v.businessIsInternational", true);
             
            if(component.find("noticeSameAsBusiness").get("v.value")) {
                    
                    component.set("v.noticeStreet", '');
                    component.set("v.noticeCity", '');
                    component.set("v.noticeState", '');
                    component.set("v.noticePostalCode", '');
            }
            component.find("noticeSameAsBusiness").set("v.disabled", true);
            component.set("v.isCopyAddress", false);
        }
        
        if(bussinessAddressType == "Australian") {
            
            component.find("recordKeepingSameAsBusiness").set("v.disabled", false);
            //component.set("v.businessIsAustralian", true);
            //component.set("v.businessIsInternational", false);
                
            component.find("noticeSameAsBusiness").set("v.disabled", false);
        }
    },
    businessEmailChange : function(component, event, helper) {
        
        if(!component.get("v.businessEmailInput"))
            component.set("v.businessEmail", "");
    },
    businessWebsiteChange : function(component, event, helper) {
        
        if(!component.get("v.businessWebsiteInput"))
            component.set("v.businessWebsite", "");
    },
    businessPhoneChange : function(component, event, helper) {
        
        if(!component.get("v.businessPhoneNumberInput"))
            component.set("v.businessPhoneNumber", "");
    },
    businessSocialMediaChange : function(component, event, helper) {
        
        if(!component.get("v.businessSocialMediaInput"))
            component.set("v.businessSocialMedia", "");
    },
    businessOtherChange : function(component, event, helper) {
        
        if(!component.get("v.businessOtherInput"))
            component.set("v.businessOther", "");
    }
})
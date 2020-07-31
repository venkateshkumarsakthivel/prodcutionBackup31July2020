({
    doInit : function(component, event, helper) {
        
        console.log('In doinit');
        
        if(component.get("v.caseId") != ""){
            helper.checkIfPrimaryDirectorIsFromNSW(component, event);
            helper.loadSectionData(component, event);   
        } 
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
    saveForm : function(component, event, helper) {
        
        if(component.get("v.directorDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                }
                return;
            }
            else {
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                    return;
                }
                else {
                    
                    document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
                    helper.saveNominatedDirector(component, event, true, false);
                }
            }
        }
        else {
            
            console.log("Director Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoDirectorError", "directorDataProvided")) {
                
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                helper.deleteAllExistingDirectorsData(component, event, true, false);
            }
        }
        
    },
    renderNextSection : function(component, event, helper) {
        
        if(component.get("v.directorDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                }
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
                return;
            }
            else {
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                    return;
                }
                else{
                    document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
                    helper.saveNominatedDirector(component, event, false, false);
                    
                }
            }
        }
        else {
            
            console.log("Director Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoDirectorError", "directorDataProvided")) {
                
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                    return;
                }
                else{
                    document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
                    helper.deleteAllExistingDirectorsData(component, event, false, false);
                }                
            }
        }
        
    },
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "ASP Form Previous"
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                        
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    renderPrevSection : function(component, event, helper) {
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionC", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartE .slds-has-error").removeClass("slds-has-error");
        //$("#formPartE .slds-form-element__help").hide();
        document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
        document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
        
        var sectionData = component.get('v.aspCase');
        console.log(sectionData);
        
        if(sectionData != undefined && component.get("v.hasSecondDirector")
           && (sectionData[1]["LastName"] == "" || sectionData[1]["LastName"] == undefined)) {
            
            component.set("v.hasSecondDirector", false);
            helper.clearDirectorAttributes(component, event, "Second");
        }
        
        if(sectionData != undefined && component.get("v.hasThirdDirector")
           && (sectionData[2]["LastName"] == "" || sectionData[2]["LastName"] == undefined)) {
            
            component.set("v.hasThirdDirector", false);
            helper.clearDirectorAttributes(component, event, "Third");
        }
        
        if(component.get("v.directorDataProvided"))
         helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(component.get("v.directorDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                }
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
                return;
            }
            else {
                
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                    return;
                }
                else {
                    
                    document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                    helper.saveSectionData(component, event, false, true);
                }
            }
        }
        else {            
            console.log("Director Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoDirectorError", "directorDataProvided")) {
                
                document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartE #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                if(helper.validateNSWStateCheck(component, event) == 0) {
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'block';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").scrollIntoView();
                    return;
                } else {                    
                    document.querySelector("#formPartE #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#formPartE #directorNotInNSWMsgDiv").style.display = 'none';
                 	helper.deleteAllExistingDirectorsData(component, event, false, true);
                }                
            }
        }
        
    },
    addMore : function(component, event, helper) {
        
        if(component.get("v.hasSecondDirector"))
            component.set("v.hasThirdDirector", true);
        
        if(!component.get("v.hasSecondDirector"))
            component.set("v.hasSecondDirector", true);
        
        console.log(component.get("v.hasSecondDirector"));
        console.log(component.get("v.hasThirdDirector"));
    },
    removeFirstRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "First");
    },
    removeSecondRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "Second");
    },
    removeThirdRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "Third");
    },
    directorChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesDirector") {
            
            component.set("v.directorDataProvided", true);
            component.set("v.hasFirstDirector", true);
        }
        else {
            
            component.set("v.directorDataProvided", false);
            helper.clearDirectors(component, event);
            component.set("v.hasFirstDirector", false);
            component.set("v.hasSecondDirector", false);
            component.set("v.hasThirdDirector", false);
        }
    },
    roleChange : function(component, event, helper) {
        
        if(component.get("v.nominatedDirectorRole") == "Manager")
            component.set("v.displayEndorsementCheck", true);
        else
            component.set("v.displayEndorsementCheck", false);
        
        if(component.get("v.nominatedDirectorRole") == "Director")
            component.set("v.displayApplicantCriminalHistoryCheck", true);
        else
            component.set("v.displayApplicantCriminalHistoryCheck", false);
            
    }
})
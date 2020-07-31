({
    doInit : function (component, event,helper) {
        
        helper.initializeCaseRecord(component, event);
    },
    toggleSectionContent : function(component, event, helper) {
        
        helper.toggleSectionContent(component, event);
    },
    cancel : function(component, event, helper) {
        
        var baseUrl = $A.get('$Label.c.Taxi_Community_Base_Url');
        window.location.href = baseUrl + 'manage-profile';
    },
    lodge : function(component, event, helper) {
      
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
            return;    
        }
        else {
            
            if(!helper.isDateValid(component,event)){
                document.querySelector("#generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                component.find("dateOfTheDecisionToBeReviewedInput").set("v.errors", [{message: $A.get("$Label.c.Internal_Review_Date_of_Decision_Error")}]);
                return; 
            }
            else {
                document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                helper.lodgeRequest(component, event);   
            }
        }
    },
})
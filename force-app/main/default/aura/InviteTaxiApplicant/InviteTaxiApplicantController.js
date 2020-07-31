({
    doInit : function(component, event, helper) {
      var caseid = component.get("v.recordId");
         console.log(caseid);
      //helper.AllApplicationsCompleted(component, event);
      helper.validateApplicationDetails(component, event); 
        
    },
    InviteApplicant : function(component, event, helper) {
         var caseid = component.get("v.recordId");
         console.log("caseidcaseid in controller"+caseid);
       helper.InviteApplicant(component, event);
    },
})
({
    handleClickNotice : function(component, event, helper) {
        component.set("v.invokeFlow",false);
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Create_Notice_from_Case",inputVariables);
    },
    
    handleClickLegislation : function(component, event, helper) {
        component.set("v.invokeFlow",false);
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Case_Legislation_Reference_Manager",inputVariables);
    },
    
    reloadClick : function(component, event, helper) {
        component.set("v.invokeFlow",true);
        //var flow = component.find("flowData");
        
        //$A.get('e.force:refreshView').fire();
        location.reload();
    }
})
({
    getNoticeRec : function (component,event) {
        
        let recordId = component.get("v.recordId");
        console.log('recordId: '+recordId);
        var getNoticeAction = component.get("c.getNoticeRecord");
        getNoticeAction.setParams({
            recordId : recordId
        });        
        getNoticeAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var noticeRecord = response.getReturnValue(); 
                component.set("v.noticeRecord",noticeRecord);
                console.log('noticeRecord: '+JSON.stringify(component.get("v.noticeRecord")));
                this.initHandler(component,event);
            } else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getNoticeAction);
    },
    
    initHandler : function (component,event) {
        let noticeRecord = component.get("v.noticeRecord");
        console.log('noticeRecord :'+JSON.stringify(noticeRecord));
        if(typeof (noticeRecord.Next_Compliance_Notice__c) != 'undefined'){
            component.set("v.noticeRecordId",noticeRecord.Next_Compliance_Notice__c);
            component.set("v.disableShowNotice",false);
            component.set("v.disableGenerateNotice",true);

        } else {
            component.set("v.disableShowNotice",true);
            component.set("v.disableGenerateNotice",false);
        }
    },
    
    handleClickHandler : function (component, event) {
        // Find the component whose aura:id is "flowData"
        let recordId = component.get("v.recordId");
        let flow = component.find("flowData");
        let inputVariables = [ 
            {
                name : 'recordId',
                type : 'String',
                value : recordId
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Generate_1st_OR_2nd_Round_Notice",inputVariables);
    },
    
    handleStatusChangeHandler : function (component, event) {
        console.log("handle Status changed called");
        console.log("handle event: "+event.getParam("status"));
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") ==='FINISHED') {
            console.log("Inside finished of  Status changed");
            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            console.log("outputVariables : "+JSON.stringify(outputVariables));
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "generatedNoticeRecord") {
                    component.set("v.noticeRecordId", outputVar.value);
                } else {
                    component.set("v.noticeRecordId", '');
                }
                this.getNoticeRec(component,event);
            }
        }
    },
    
    navigateToRecordHandler : function (component, event) {
        var noticeRecordId = component.get("v.noticeRecordId");
        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");      
        redirect.setParams({
            "recordId": noticeRecordId
        });
        redirect.fire();
    }
})
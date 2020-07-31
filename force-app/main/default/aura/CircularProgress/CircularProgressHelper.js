({
    computeProgress : function(component, event, helper)  {
        
        var totalVal = component.get("v.totalProgress");
        var actualVal = component.get("v.actualProgress"); 
        
        if(totalVal == actualVal 
           && totalVal != 0
           && actualVal != 0
           && component.get("v.refreshIntervalId") != undefined)
          window.clearInterval(component.get("v.refreshIntervalId"));
        
        var threshold = component.get("v.threshold");
        var beforeTheme = component.get("v.themeBeforeThreshold");
        var afterTheme = component.get("v.themeAfterThreshold");
        
        this.callApexMethod(component, event, helper, "Eligibility_Check_Total_Count__c", "Total__c");
        
    },
    callApexMethod : function(component, event, helper, txt_totalVal, txt_actualVal)  {
       
        var action = component.get('c.computePercentage');
        var txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordId : txt_recordId,
            sObjectName : txt_sObjectName,
            totalValueFieldName : txt_totalVal,
            actualValueFieldName : txt_actualVal
        });
        
        action.setCallback(this, function(a) {
            
            if(a.getState() === 'SUCCESS') {
            	
            	var retObj =  JSON.parse(a.getReturnValue());
            	
                console.log('Group Status: '+retObj.queryGroupStatus);
                console.log('Interval Id: '+component.get("v.refreshIntervalId"));
                console.log('Total Progress: '+component.get("v.totalProgress"));
                console.log('Actual Progress: '+component.get("v.actualProgress"));
                
                
            	//DVD Query Group batch processing is completed, so stop the refresh event
            	if(retObj.queryGroupStatus == "Completed" 
                    && component.get("v.refreshIntervalId") != undefined
                    && component.get("v.totalProgress") != 0
                    && component.get("v.actualProgress") != 0
                    && component.get("v.actualProgress") == component.get("v.totalProgress")) {
            		window.clearInterval(component.get("v.refreshIntervalId"));
            	}
                
                var threshold = component.get("v.threshold");
                var beforeTheme = component.get("v.themeBeforeThreshold");
                var afterTheme = component.get("v.themeAfterThreshold");
                
                
                if(retObj.actual == null)
                    retObj.actual = 0;
                
                if(retObj.total == null)
                    retObj.total = 0;
                
                component.set("v.totalProgress" , retObj.total);
                component.set("v.actualProgress" , retObj.actual); 
                
                
                if(retObj.total > 0)
                  component.set("v.threshold" , parseInt(retObj.total/2));
                else
                  component.set("v.threshold" , 0); 
                
                
                if(parseInt(retObj.actual) >= threshold){
                    component.set("v.theme" , afterTheme );
                }else{
                    component.set("v.theme" , beforeTheme );
                }
                
                
                var progressVal = parseInt((retObj.val *360/100)) ; 
                console.log('progress val: ' + progressVal);
                console.log('Actual: '+retObj.actual);
                
                component.set("v.cirDeg" , progressVal);
                component.set("v.perText" , parseInt(retObj.val)  +'%');
                
                var updateDVDCountEvent = component.getEvent("updateDVDCount");
                updateDVDCountEvent.setParams({"recordId": txt_recordId});
                updateDVDCountEvent.setParams({"redCount": retObj.redCount});
                updateDVDCountEvent.setParams({"greenCount": retObj.greenCount});
                updateDVDCountEvent.setParams({"whiteCount": retObj.whiteCount});
                updateDVDCountEvent.fire();              
            }  
        });
        $A.enqueueAction(action);  
    }
})
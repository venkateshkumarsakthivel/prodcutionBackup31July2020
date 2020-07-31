({
    getData : function(cmp){
        var caseRecordId = cmp.get("v.recordId");
        var action = cmp.get('c.getAuthorisations');
        action.setParams({  caseRecordId : caseRecordId  });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != ""){
                    cmp.set('v.mydata', response.getReturnValue());
                }else{
                    cmp.set("v.hasGrantedAuthorisations", "false");
                }
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})
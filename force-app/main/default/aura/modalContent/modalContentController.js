({
  init: function(cmp) {
    var inputVariables = [
      { name: "recordId", type: "String", value: cmp.get("v.recordId") }
    ];
    var flow = cmp.find("flowData");

    flow.startFlow(cmp.get("v.flowName"), inputVariables);
  },

  handleStatusChange: function(cmp, event) {
    var recordtoNavigate = cmp.get("v.recordId");


    if (
      event.getParam("status") === "FINISHED" ||
      event.getParam("status") === "FINISHED_SCREEN"
    ) {
      var outputVariables = event.getParam("outputVariables");
      var outputVar;

      if (outputVariables != null) {
        for (var i = 0; i < outputVariables.length; i++) {
          outputVar = outputVariables[i];
          if (outputVar.name === cmp.get("v.outputVariable")) {
            recordtoNavigate = outputVar.value;

          }
        }
      }

      $A.get('e.force:refreshView').fire();

      

        if(cmp.get('v.navigate') != false) { 
              var urlEvent = $A.get("e.force:navigateToSObject");
              urlEvent.setParams({
                recordId: recordtoNavigate,
                isredirect: "true"
              });
              urlEvent.fire();
        }
        else{
            cmp.find("overlayLib").notifyClose();
        }
      
    }
  }
});